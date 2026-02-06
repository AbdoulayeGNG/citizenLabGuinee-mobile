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
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
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
      rethrow;
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

  /// Récupérer tous les membres de l'équipe
  Future<List<Map<String, dynamic>>> fetchTeamMembers() async {
    final result = await executeQuery(getAllMembers());

    // La requête retourne users.edges - on extrait les nodes
    final edges = result.data?['users']?['edges'] ?? [];
    print('[DEBUG GraphQLService] Réponse users: ${result.data}');

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
