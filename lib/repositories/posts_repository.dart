import 'package:hive/hive.dart';
import '../models/hive_post.dart';
import '../models/post.dart';

class PostsRepository {
  static const String _boxName = 'postsBox';
  static const String _lastSyncKey = 'posts_last_sync';

  /// Get the posts box
  Box<HivePost> get _box => Hive.box<HivePost>(_boxName);

  /// Get metadata box for sync timestamps
  Box get _metadataBox => Hive.box('metadataBox');

  /// Get all posts from local cache
  Future<List<HivePost>> getAllPostsFromCache() async {
    try {
      return _box.values.toList();
    } catch (e) {
      print('Erreur lors de la lecture des posts du cache: $e');
      return [];
    }
  }

  /// Debug: return a preview of stored entries (key -> toJson())
  Future<Map<String, Map<String, dynamic>>> getPreview({int limit = 10}) async {
    final out = <String, Map<String, dynamic>>{};
    try {
      final keys = _box.keys.cast<dynamic>().take(limit);
      for (final k in keys) {
        final v = _box.get(k);
        if (v != null) out[k.toString()] = v.toJson();
      }
    } catch (e) {
      print('PostsRepository.getPreview error: $e');
    }
    return out;
  }

  /// Save posts to local cache
  Future<void> savePosts(List<Post> posts) async {
    try {
      await _box.clear();
      final hivePosts = posts.map((post) => HivePost.fromPost(post)).toList();

      for (int i = 0; i < hivePosts.length; i++) {
        // use put with id key to be safe
        await _box.put(hivePosts[i].id, hivePosts[i]);
      }

      // Update last sync time
      await _metadataBox.put(_lastSyncKey, DateTime.now().toIso8601String());

      // Debug log
      print('PostsRepository: saved ${hivePosts.length} posts to Hive');
    } catch (e) {
      print('Erreur lors de la sauvegarde des posts: $e');
    }
  }

  /// Save a single post to cache
  Future<void> savePost(Post post) async {
    try {
      final hivePost = HivePost.fromPost(post);
      await _box.put(post.id, hivePost);

      // Debug log
      print('PostsRepository: saved post ${post.id} to Hive');
    } catch (e) {
      print('Erreur lors de la sauvegarde du post: $e');
    }
  }

  /// Get a post by ID from cache
  Future<HivePost?> getPostById(String postId) async {
    try {
      return _box.get(postId);
    } catch (e) {
      print('Erreur lors de la lecture du post: $e');
      return null;
    }
  }

  /// Get posts by category from cache
  Future<List<HivePost>> getPostsByCategory(String categorySlug) async {
    try {
      final allPosts = _box.values.toList();
      return allPosts
          .where((post) => post.categories.contains(categorySlug))
          .toList();
    } catch (e) {
      print('Erreur lors de la filtrage des posts par catégorie: $e');
      return [];
    }
  }

  /// Search posts by title or excerpt
  Future<List<HivePost>> searchPosts(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final allPosts = _box.values.toList();

      return allPosts
          .where(
            (post) =>
                post.title.toLowerCase().contains(lowerQuery) ||
                (post.excerpt?.toLowerCase().contains(lowerQuery) ?? false) ||
                (post.content?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche de posts: $e');
      return [];
    }
  }

  /// Clear all posts from cache
  Future<void> clearAllPosts() async {
    try {
      await _box.clear();
      await _metadataBox.delete(_lastSyncKey);
    } catch (e) {
      print('Erreur lors du vidage du cache des posts: $e');
    }
  }

  /// Get the last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final syncTimeStr = _metadataBox.get(_lastSyncKey) as String?;
      if (syncTimeStr != null) {
        return DateTime.parse(syncTimeStr);
      }
    } catch (e) {
      print('Erreur lors de la lecture du timestamp de synchro: $e');
    }
    return null;
  }

  /// Check if cache needs refresh (older than X minutes)
  Future<bool> needsRefresh({int minutesThreshold = 60}) async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;

      final now = DateTime.now();
      final difference = now.difference(lastSync).inMinutes;
      return difference > minutesThreshold;
    } catch (e) {
      return true;
    }
  }
}
