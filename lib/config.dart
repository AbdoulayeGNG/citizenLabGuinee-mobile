/// Configuration de l'API GraphQL pour CitizenLab Guinée
///
/// À adapter selon votre environnement (développement, production, etc.)

class ApiConfig {
  /// URL de base du WordPress / API GraphQL
  /// IMPORTANT: À adapter avec votre URL réelle
  static const String graphqlEndpoint = String.fromEnvironment(
    'GRAPHQL_ENDPOINT',
    defaultValue: 'https://citizenlab.africtivistes.org/guinee/graphql',
  );

  /// Timeout par défaut pour les requêtes (en secondes)
  static const int requestTimeoutSeconds = 30;

  /// Cache stratégie
  static const bool cacheEnabled = true;
  static const int cacheDurationMinutes = 60;

  /// Nombre d'articles par page
  static const int postsPerPage = 10;
  static const int maxPostsToLoad = 20;

  /// Nombre de membres par page
  static const int membersPerPage = 20;

  /// Debug mode - Active les logs détaillés
  static const bool debugMode = true;

  /// Configuration des URLs de partage
  static const whatsappShareUrl =
      'https://wa.me/?text='; // Complété avec l'URL de l'article
  static const facebookShareUrl = 'https://www.facebook.com/sharer/sharer.php';

  /// Valeurs par défaut pour les images manquantes
  static const defaultImageUrl = 'assets/images/placeholder.png';
  static const defaultAvatarUrl = 'assets/images/default_avatar.png';

  /// Menu ID dans WordPress
  static const String primaryMenuId = 'HEADER_MENU';

  /// Catégories spéciales
  static const String featuredCategorySlug = 'featured';
  static const String projectsCategorySlug = 'projects';

  /// Textes par défaut
  static const String appName = 'CitizenLab Guinée';
  static const String appTagline =
      'Informations citoyennes, éducatives et médiatiques';

  /// URLs statiques (si besoin)
  static const String aboutPageUri = '/about';
  static const String contactPageUri = '/contact';
}

/// Configuration pour environnements différents
class EnvironmentConfig {
  static bool isProduction() {
    return const bool.fromEnvironment('dart.vm.product', defaultValue: false);
  }

  static bool isDevelopment() {
    return !isProduction();
  }

  /// Obtenir l'endpoint selon l'environnement
  static String getGraphQLEndpoint() {
    if (isProduction()) {
      return 'https://citizenlab.africtivistes.org/senegal/graphql';
    } else {
      return 'https://citizenlab.africtivistes.org/senegal/graphql'; 
    }
  }

  /// Obtenir le timeout selon l'environnement
  static int getRequestTimeout() {
    return isDevelopment() ? 60 : 30;
  }
}
