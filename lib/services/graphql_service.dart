import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_queries.dart';

/// Service GraphQL pour communiquer avec l'API WordPress
class GraphQLService {
  final GraphQLClient graphQLClient;
  static const String graphqlEndpoint =
      'https://citizenlab.africtivistes.org/guinee/graphql'; // À adapter selon votre URL

  GraphQLService({required this.graphQLClient});

  /// Factory constructor pour créer une instance avec configuration par défaut
  factory GraphQLService.defaultConfig() {
    final httpLink = HttpLink(graphqlEndpoint);

    return GraphQLService(
      graphQLClient: GraphQLClient(link: httpLink, cache: GraphQLCache()),
    );
  }

  /// Exécuter une requête GraphQL
  Future<QueryResult> executeQuery(
    String query, {
    Map<String, dynamic>? variables,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 2,
  }) async {
    // Helper to strip ACF blocks from queries when the WP schema doesn't expose them
    String stripAcfBlocks(String q) {
      return q.replaceAll(RegExp(r'acf\s*\{[^}]*\}', multiLine: true), '');
    }

    String currentQuery = query;
    bool acfStripped = false;

    int attempt = 0;
    while (true) {
      attempt++;
      final QueryOptions options = QueryOptions(
        document: gql(currentQuery),
        variables: variables ?? {},
      );

      try {
        final result = await graphQLClient
            .query(options)
            .timeout(timeout)
            .catchError((error) {
              throw GraphQLException(
                'Erreur réseau lors de la requête GraphQL: $error',
              );
            });

        if (result.hasException) {
          throw GraphQLException(
            'Erreur GraphQL: ${result.exception.toString()}',
          );
        }

        return result;
      } catch (e) {
        final message = e.toString();

        // If the server rejects 'acf' field, strip acf blocks and retry once
        if (!acfStripped && message.contains('Cannot query field "acf"')) {
          acfStripped = true;
          currentQuery = stripAcfBlocks(currentQuery);
          print(
            '[GraphQLService] Detected missing ACF field, retrying without acf blocks',
          );
          continue;
        }

        // If we've exhausted retries, rethrow the exception
        if (attempt > maxRetries) rethrow;

        // On transient errors (timeout / network), wait exponential backoff then retry
        final backoffMillis = 300 * (1 << (attempt - 1));
        print(
          '[GraphQLService] query failed (attempt $attempt) - retrying in ${backoffMillis}ms: $e',
        );
        await Future.delayed(Duration(milliseconds: backoffMillis));
      }
    }
  }

  /// Récupérer le menu de navigation
  Future<Map<String, dynamic>> fetchMenu() async {
    final result = await executeQuery(navQuery());
    print('[DEBUG] fetchMenu result.data: ${result.data}');

    // Nav query now returns `menus.edges[n].node` — pick the first menu node if present
    final menus = result.data?['menus'];
    print('[DEBUG] fetchMenu menus: $menus');

    if (menus is List && menus.isNotEmpty) {
      final first = menus.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
      return {};
    } else if (menus is Map) {
      // Si menus est directement un Map (structure alternative)
      return Map<String, dynamic>.from(menus);
    }
    return {};
  }

  /// Récupérer les derniers articles
  Future<List<Map<String, dynamic>>> fetchLatestPosts({
    int first = 10,
    String? after,
  }) async {
    final result = await executeQuery(
      findLatestPostsAPI(first: first, after: after),
      variables: {'first': first, if (after != null) 'after': after},
    );

    final edges = result.data?['posts']?['edges'] ?? [];
    return List<Map<String, dynamic>>.from(
      edges.map((edge) => edge['node'] ?? {}),
    );
  }

  /// Récupérer un nœud (Post, Page, Category) par URI
  Future<Map<String, dynamic>> fetchNodeByURI(String uri) async {
    final result = await executeQuery(
      getNodeByURI(uri),
      variables: {'uri': uri},
    );

    return result.data?['nodeByUri'] ?? {};
  }

  /// Récupérer un Post par slug (idType: SLUG)
  Future<Map<String, dynamic>> fetchPostBySlug(String slug) async {
    final result = await executeQuery(
      getPostBySlugQuery(),
      variables: {'slug': slug},
    );

    // GraphQL returns { 'post': { ... } }
    final post = result.data?['post'];
    if (post is Map<String, dynamic>) return Map<String, dynamic>.from(post);
    return {};
  }

  /// Récupérer tous les membres de l'équipe
  Future<List<Map<String, dynamic>>> fetchTeamMembers() async {
    final result = await executeQuery(getAllMembers());

    // Try to read equipes.nodes first (new query), fallback to users.edges for older schema
    print('[DEBUG GraphQLService] fetchTeamMembers response: ${result.data}');

    final equipesNodes = result.data?['equipes']?['nodes'];
    if (equipesNodes is List) {
      return List<Map<String, dynamic>>.from(
        equipesNodes.map((node) {
          final m = Map<String, dynamic>.from(node as Map<String, dynamic>);

          // Normalize to the shape TeamMember.fromGraphql expects
          if ((m['name'] == null || (m['name'] as String).isEmpty) &&
              m['title'] != null) {
            m['name'] = m['title'];
          }

          // Map featuredImage.node.mediaItemUrl/sourceUrl -> avatar.url
          final featured = m['featuredImage'];
          if (featured is Map && featured['node'] is Map) {
            final media = featured['node'] as Map<String, dynamic>;
            final mediaUrl =
                media['mediaItemUrl'] ?? media['sourceUrl'] ?? media['url'];
            if (mediaUrl != null) {
              m['avatar'] = {'url': mediaUrl};
            }
            if (media['altText'] != null) {
              m['altText'] = media['altText'];
            }
          }

          return m;
        }),
      );
    }

    // Fallback to legacy users query
    final edges = result.data?['users']?['edges'] ?? [];
    return List<Map<String, dynamic>>.from(
      edges.map((edge) => edge['node'] ?? {}),
    );
  }

  /// Récupérer toutes les catégories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final result = await executeQuery(getAllCategoriesQuery());

    final edges = result.data?['categories']?['edges'] ?? [];
    return List<Map<String, dynamic>>.from(
      edges.map((edge) => edge['node'] ?? {}),
    );
  }

  /// Rechercher des articles par mot-clé
  Future<List<Map<String, dynamic>>> searchPosts(
    String searchTerm, {
    int first = 10,
  }) async {
    final result = await executeQuery(
      searchPostsQuery(searchTerm, first: first),
      variables: {'search': searchTerm, 'first': first},
    );

    final edges = result.data?['posts']?['edges'] ?? [];
    return List<Map<String, dynamic>>.from(
      edges.map((edge) => edge['node'] ?? {}),
    );
  }

  /// Récupérer les articles d'une catégorie
  Future<Map<String, dynamic>> fetchPostsByCategory(
    String categorySlug, {
    int first = 10,
    String? after,
  }) async {
    final result = await executeQuery(
      getPostsByCategoryQuery(categorySlug, first: first, after: after),
      variables: {
        'slug': categorySlug,
        'first': first,
        if (after != null) 'after': after,
      },
    );

    final edges = result.data?['categories']?['edges'] ?? [];
    if (edges.isEmpty) return {};

    return edges.first['node'] ?? {};
  }

  /// Récupérer les données de la page d'accueil
  Future<Map<String, dynamic>> fetchHomePageData() async {
    final result = await executeQuery(homePageDataQuery());
    return result.data ?? {};
  }
}

/// Exception personnalisée pour les erreurs GraphQL
class GraphQLException implements Exception {
  final String message;

  GraphQLException(this.message);

  @override
  String toString() => 'GraphQLException: $message';
}
