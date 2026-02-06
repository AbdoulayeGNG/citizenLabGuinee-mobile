/// Constantes et messages pour l'application
class AppStrings {
  // Titres généraux
  static const String appName = 'CitizenLab Guinée';
  static const String appTagline = 'Informations citoyennes';

  // Navigation
  static const String navHome = 'Accueil';
  static const String navNews = 'Actualités';
  static const String navCategories = 'Catégories';
  static const String navTeam = 'Équipe';
  static const String navSearch = 'Recherche';
  static const String navAbout = 'À propos';

  // Écrans
  static const String screenArticle = 'Article';
  static const String screenCategory = 'Catégorie';
  static const String screenTeam = 'Notre Équipe';
  static const String screenSearch = 'Recherche';

  // Sections
  static const String sectionLatestNews = 'Dernières actualités';
  static const String sectionRecentProjects = 'Projets récents';
  static const String sectionFeatured = 'Contenus mis en avant';
  static const String sectionAbout = 'Qui sommes-nous';
  static const String sectionRelated = 'Articles connexes';

  // Boutons
  static const String btnReadMore = 'Lire plus';
  static const String btnLearnMore = 'En savoir plus';
  static const String btnShare = 'Partager';
  static const String btnRetry = 'Réessayer';
  static const String btnRefresh = 'Actualiser';
  static const String btnClose = 'Fermer';
  static const String btnCancel = 'Annuler';

  // Messages d'erreur
  static const String errorLoadingData =
      'Erreur lors du chargement des données';
  static const String errorArticleNotFound = 'Article introuvable';
  static const String errorNoResults = 'Aucun résultat trouvé';
  static const String errorOffline = 'Vous êtes hors ligne';
  static const String errorNetworkTimeout = 'Délai d\'attente dépassé';
  static const String errorGeneric = 'Une erreur s\'est produite';

  // Messages d'info
  static const String infoSearch = 'Tapez pour rechercher';
  static const String infoLoading = 'Chargement...';
  static const String infoOfflineMode = 'Mode hors ligne activé';
  static const String infoNoArticles = 'Aucun article trouvé';
  static const String infoNoMembers = 'Aucun membre trouvé';
  static const String infoNoCategories = 'Aucune catégorie trouvée';

  // Partage
  static const String shareVia = 'Partager via...';
  static const String shareWhatsApp = 'WhatsApp';
  static const String shareFacebook = 'Facebook';
  static const String shareLink = 'Copier le lien';
  static const String shareCopied = 'Lien copié!';

  // Recherche
  static const String searchArticles = 'Rechercher des articles...';
  static const String searchPlaceholder = 'Que cherchez-vous?';
  static const String searchNoResults = 'Aucun article correspondant';

  // Équipe
  static const String teamRole = 'Fonction';
  static const String teamEmail = 'Email';
  static const String teamContact = 'Contacter';

  // Autres
  static const String dateFormat = 'dd MMMM yyyy';
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String readTime = 'min de lecture';
  static const String views = 'vues';
  static const String by = 'Par';
}

/// Couleurs personalizées
class AppColors {
  static const int primaryGreen = 0xFF009460;
  static const int secondaryRed = 0xFFCE1126;
  static const int tertiaryYellow = 0xFFFCD116;
  static const int lightGrey = 0xFFF5F5F5;
  static const int darkGrey = 0xFF333333;
}

/// Tailles typographiques
class AppFontSizes {
  static const double headlineSmall = 20;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelSmall = 10;
}

/// Espacements
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Rayons de border
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 20;
}
