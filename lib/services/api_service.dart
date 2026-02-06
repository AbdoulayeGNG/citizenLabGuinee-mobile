import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/post.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/team_member.dart';
import '../models/page.dart' as page_model;
import '../repositories/posts_repository.dart';
import '../repositories/categories_repository.dart';
import '../repositories/teams_repository.dart';
import 'graphql_service.dart';

class ApiService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final GraphQLService _graphqlService;

  // Initialize repositories (Hive only)
  final PostsRepository _postsRepo = PostsRepository();
  final CategoriesRepository _categoriesRepo = CategoriesRepository();
  final TeamsRepository _teamsRepo = TeamsRepository();

  // Data
  List<Post> _posts = [];
  List<MenuItem> _menuItems = [];
  List<Category> _categories = [];
  List<TeamMember> _teamMembers = [];

  // State
  bool _isOffline = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFetching = false; // Prevent concurrent fetch calls

  // Getters
  List<Post> get posts => _posts;
  List<MenuItem> get menuItems => _menuItems;
  List<Category> get categories => _categories;
  List<TeamMember> get teamMembers => _teamMembers;
  bool get isOffline => _isOffline;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ApiService() {
    _initializeGraphQL();
    // connectivity listener stays active; actual initial checks happen in init()
    _connectivity.onConnectivityChanged.listen((result) {
      _isOffline = result == ConnectivityResult.none;
      _safeNotify();
      if (!_isOffline && !_isFetching) {
        debugPrint('ApiService: connectivity regained, fetching data');
        _fetchAllData();
      }
    });
  }

  /// Safely notify listeners asynchronously to avoid calling setState during build.
  void _safeNotify() {
    Future.microtask(() => notifyListeners());
  }

  /// Must be called after construction to perform async initialization.
  /// This returns quickly after loading cache, and fetches fresh data in background.
  Future<void> init() async {
    try {
      debugPrint('ApiService.init(): starting initialization');
      await _checkConnectivity();
      debugPrint(
        'ApiService.init(): connectivity check done, isOffline=$_isOffline',
      );

      // Load cache synchronously (fast)
      await _loadCachedData();
      debugPrint('ApiService.init(): cache loaded, posts=${_posts.length}');

      // If offline, we're done - use cached data
      if (_isOffline) {
        debugPrint('ApiService.init(): offline mode, using cached data');
        return;
      }

      // If online, fetch fresh data WITHOUT blocking - just fire and forget
      debugPrint(
        'ApiService.init(): online, fetching fresh data in background...',
      );
      unawaited(_fetchAllData());
    } catch (e) {
      debugPrint('ApiService.init() error: $e');
      _errorMessage = 'Erreur initialisation: $e';
      notifyListeners();
    }
  }

  void _initializeGraphQL() {
    _graphqlService = GraphQLService.defaultConfig();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _isOffline = connectivityResult == ConnectivityResult.none;
    _safeNotify();
  }

  /// Load data from Hive only (no legacy cache fallback)
  Future<void> _loadCachedData() async {
    try {
      debugPrint('ApiService._loadCachedData(): loading from Hive...');

      // Load from Hive repositories only
      final hivePosts = await _postsRepo.getAllPostsFromCache();
      if (hivePosts.isNotEmpty) {
        _posts = hivePosts
            .map(
              (hp) => Post(
                id: hp.id,
                title: hp.title,
                slug: hp.slug ?? '',
                content: hp.content ?? '',
                excerpt: hp.excerpt,
                date: hp.date?.toString() ?? '',
                imageUrl: hp.imageUrl,
                imageAlt: hp.imageAlt,
                authorName: hp.authorName,
                categories: hp.categories,
              ),
            )
            .toList();
        debugPrint(
          'ApiService._loadCachedData(): loaded ${_posts.length} posts from Hive',
        );
      }

      final hiveCategories = await _categoriesRepo.getAllCategoriesFromCache();
      if (hiveCategories.isNotEmpty) {
        _categories = hiveCategories
            .map(
              (hc) => Category(
                id: hc.id,
                name: hc.name,
                slug: hc.slug ?? '',
                description: hc.description,
              ),
            )
            .toList();
        debugPrint(
          'ApiService._loadCachedData(): loaded ${_categories.length} categories from Hive',
        );
      }

      final hiveTeams = await _teamsRepo.getAllTeamMembersFromCache();
      if (hiveTeams.isNotEmpty) {
        _teamMembers = hiveTeams
            .map(
              (ht) => TeamMember(
                id: ht.id,
                name: ht.name,
                role: ht.role,
                team: ht.team,
                photoUrl: ht.imageUrl,
                facebook: ht.facebook,
                linkedin: ht.linkedin,
                twitter: ht.twitter,
                instagram: ht.instagram,
                description: null,
              ),
            )
            .toList();
        debugPrint(
          'ApiService._loadCachedData(): loaded ${_teamMembers.length} team members from Hive',
        );
      }

      notifyListeners();
    } catch (e, st) {
      debugPrint('ApiService._loadCachedData() error: $e\n$st');
      _errorMessage = 'Erreur lors du chargement du cache: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllData() async {
    if (_isOffline || _isFetching) {
      debugPrint(
        'ApiService._fetchAllData(): skipping (offline=$_isOffline, fetching=$_isFetching)',
      );
      return;
    }

    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    debugPrint('ApiService._fetchAllData(): starting...');
    _safeNotify();

    try {
      await Future.wait([
        _fetchPosts(),
        _fetchMenu(),
        _fetchCategories(),
        _fetchTeamMembers(),
      ], eagerError: true);
      debugPrint('ApiService._fetchAllData(): completed successfully');
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des données: $e';
      debugPrint('Erreur ApiService: $_errorMessage');
    } finally {
      _isFetching = false;
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final postsData = await _graphqlService.fetchLatestPosts(first: 20);
      _posts = postsData
          .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Save to Hive only
      await _postsRepo.savePosts(_posts);
      _safeNotify();
      debugPrint(
        'ApiService._fetchPosts(): fetched and saved ${_posts.length} posts',
      );
    } catch (e) {
      debugPrint('Erreur fetch posts: $e');
      rethrow;
    }
  }

  Future<void> _fetchMenu() async {
    try {
      final menuData = await _graphqlService.fetchMenu();
      if (menuData.isNotEmpty) {
        final edges = menuData['menuItems']?['edges'] ?? [];
        _menuItems = (edges as List)
            .cast<Map>()
            .map(
              (edge) => MenuItem.fromJson(
                Map<String, dynamic>.from(edge['node'] as Map),
              ),
            )
            .toList();
        _safeNotify();
        debugPrint(
          'ApiService._fetchMenu(): fetched ${_menuItems.length} menu items',
        );
      }
    } catch (e) {
      debugPrint('Erreur fetch menu: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categoriesData = await _graphqlService.fetchCategories();
      _categories = categoriesData
          .map((json) => Category.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Save to Hive only
      await _categoriesRepo.saveCategories(_categories);
      _safeNotify();
      debugPrint(
        'ApiService._fetchCategories(): fetched and saved ${_categories.length} categories',
      );
    } catch (e) {
      debugPrint('Erreur fetch categories: $e');
    }
  }

  Future<void> _fetchTeamMembers() async {
    try {
      final membersData = await _graphqlService.fetchTeamMembers();
      _teamMembers = membersData
          .map(
            (json) => TeamMember.fromGraphql(Map<String, dynamic>.from(json)),
          )
          .toList();

      // Save to Hive only
      await _teamsRepo.saveTeamMembers(_teamMembers);
      _safeNotify();
      debugPrint(
        'ApiService._fetchTeamMembers(): fetched and saved ${_teamMembers.length} team members',
      );
    } catch (e) {
      debugPrint('Erreur fetch team members: $e');
    }
  }

  Future<void> refreshData() async {
    _checkConnectivity();
    if (!_isOffline) {
      await _fetchAllData();
    }
  }

  /// Diagnostic helper: return counts of items stored in Hive via repositories
  Future<Map<String, int>> getCacheCounts() async {
    final posts = await _postsRepo.getAllPostsFromCache();
    final cats = await _categoriesRepo.getAllCategoriesFromCache();
    final teams = await _teamsRepo.getAllTeamMembersFromCache();
    return {
      'posts': posts.length,
      'categories': cats.length,
      'teams': teams.length,
    };
  }

  /// Return small preview maps for debug (first N entries)
  Future<Map<String, Map<String, Map<String, dynamic>>>> getCachePreviews({
    int limit = 10,
  }) async {
    final postsPreview = await _postsRepo.getPreview(limit: limit);
    final catsPreview = <String, Map<String, dynamic>>{};
    final teamsPreview = await _teamsRepo.getPreview(limit: limit);
    return {
      'posts': postsPreview,
      'categories': catsPreview,
      'teams': teamsPreview,
    };
  }

  Future<Post?> fetchPostById(String id) async {
    try {
      final nodeData = await _graphqlService.fetchNodeByURI(id);
      if (nodeData.isNotEmpty) {
        return Post.fromJson(Map<String, dynamic>.from(nodeData));
      }
    } catch (e) {
      debugPrint('Erreur fetch post: $e');
    }
    return null;
  }

  Future<page_model.Page?> fetchPageByUri(String uri) async {
    try {
      final nodeData = await _graphqlService.fetchNodeByURI(uri);
      if (nodeData.isNotEmpty) {
        return page_model.Page.fromJson(Map<String, dynamic>.from(nodeData));
      }
    } catch (e) {
      debugPrint('Erreur fetch page: $e');
    }
    return null;
  }

  Future<List<Post>> searchPosts(String query) async {
    if (_isOffline) return [];
    try {
      final postsData = await _graphqlService.searchPosts(query, first: 20);
      return postsData
          .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Erreur search: $e');
      return [];
    }
  }

  Future<List<Post>> fetchPostsByCategory(String categorySlug) async {
    if (_isOffline) return [];
    try {
      final categoryData = await _graphqlService.fetchPostsByCategory(
        categorySlug,
        first: 20,
      );
      final posts = categoryData['posts']?['edges'] ?? [];
      return (posts as List)
          .cast<Map>()
          .map(
            (edge) =>
                Post.fromJson(Map<String, dynamic>.from(edge['node'] as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur fetch posts by category: $e');
      return [];
    }
  }
}
