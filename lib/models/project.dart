/// Modèle pour une catégorie de projet réalisée par CitizenLab Guinée
class ProjectCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<String> themes;
  final String color;

  const ProjectCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.themes,
    required this.color,
  });

  /// Données statiques des projets réalisés
  static List<ProjectCategory> get projects => [
    ProjectCategory(
      id: '1',
      title: 'Développement d\'applications',
      description:
          'Création de solutions numériques innovantes pour organisations et communautés',
      icon: '📱',
      themes: [
        'Applications Web',
        'Applications Mobiles',
        'Solutions Numériques',
        'UX/UI Design',
      ],
      color: '#CE1126', // Rouge
    ),
    ProjectCategory(
      id: '2',
      title: 'Formations numériques',
      description:
          'Renforcement des capacités à travers des formations spécialisées en technologies',
      icon: '📚',
      themes: [
        'Cybersécurité',
        'Intelligence Artificielle',
        'CivicTech',
        'Démocratie numérique',
        'Développement Web/Mobile',
      ],
      color: '#FCD116', // Jaune
    ),
    ProjectCategory(
      id: '3',
      title: 'Création de contenus citoyens',
      description:
          'Production de contenu éducatif pour sensibiliser sur les enjeux démocratiques',
      icon: '✍️',
      themes: [
        'Sensibilisation démocratique',
        'Droits civiques',
        'Participation citoyenne',
        'Éducation civique',
      ],
      color: '#009460', // Vert
    ),
    ProjectCategory(
      id: '4',
      title: 'Assistance et accompagnement',
      description:
          'Soutien personnalisé pour les jeunes, communautés et organisations',
      icon: '🤝',
      themes: [
        'Accompagnement jeunesse',
        'Conseil technologique',
        'Support communautaire',
        'Mentorat numérique',
      ],
      color: '#CE1126', // Rouge
    ),
    ProjectCategory(
      id: '5',
      title: 'Analyse de données',
      description:
          'Exploitation et analyse des données publiques pour comprendre les réalités guinéennes',
      icon: '📊',
      themes: [
        'Données publiques',
        'Rapports analytiques',
        'Études sociales',
        'Insights numériques',
      ],
      color: '#FCD116', // Jaune
    ),
  ];
}

/// Ancien modèle Project conservé pour la rétrocompatibilité
class Project {
  final int id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String imageUrl;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.imageUrl,
  });

  // Dummy data
  static List<Project> dummyProjects = [
    Project(
      id: 1,
      title: 'Participation Citoyenne',
      description:
          'Une plateforme numérique permettant aux citoyens de contribuer directement aux décisions locales et nationales. Engagez-vous, votez et faites entendre votre voix.',
      category: 'Démocratie',
      status: 'En cours',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
    Project(
      id: 2,
      title: 'Innovation Démocratique',
      description:
          'Développement de solutions technologiques innovantes pour renforcer les processus démocratiques. Transparence, équité et inclusion au cœur du projet.',
      category: 'Innovation',
      status: 'En cours',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
    Project(
      id: 3,
      title: 'Transparence Publique',
      description:
          'Système ouvert de suivi des finances publiques et des décisions gouvernementales. Donnez accès aux citoyens pour une meilleure responsabilité.',
      category: 'Gouvernance',
      status: 'Lancé',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
    Project(
      id: 4,
      title: 'Jeunes Innovateurs',
      description:
          'Programme d\'incubation pour les jeunes entrepreneurs sociaux. Créez des solutions qui changent la Guinée et l\'Afrique de l\'Ouest.',
      category: 'Jeunesse',
      status: 'En cours',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
    Project(
      id: 5,
      title: 'Gouvernance Numérique',
      description:
          'Transformation numérique des services publics pour plus de fluidité et d\'accessibilité. Un État plus proche de ses citoyens.',
      category: 'Technologie',
      status: 'Planifié',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
    Project(
      id: 6,
      title: 'Civisme en Action',
      description:
          'Campagnes de sensibilisation et formation civique à travers toute la Guinée. Construire une culture de responsabilité citoyenne.',
      category: 'Éducation',
      status: 'En cours',
      imageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80',
    ),
  ];
}
