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
