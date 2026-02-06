/// Modèle pour un membre de l'équipe
class TeamMember {
  final String id;
  final String name;
  final String? role; // fonction
  final String? team; // équipe
  final String? photoUrl;
  final String? facebook;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? description;

  TeamMember({
    required this.id,
    required this.name,
    this.role,
    this.team,
    this.photoUrl,
    this.facebook,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.description,
  });

  /// Factory helper pour parser la réponse GraphQL
  factory TeamMember.fromGraphql(Map<String, dynamic> json) {
    // DEBUG: affiche les données brutes
    print('[DEBUG] TeamMember.fromGraphql reçu: $json');

    // Récupérer l'image depuis avatar.url (structure users GraphQL)
    String? photo;
    final avatar = json['avatar'];
    if (avatar is Map && avatar['url'] is String) {
      photo = avatar['url'] as String;
    }
    print('[DEBUG] Image URL: $photo');

    // Récupérer rôle et équipe depuis fonctions (si disponible)
    String? role;
    String? team;
    final fonctions = json['fonctions'];
    if (fonctions is Map) {
      role = fonctions['fonction'] as String?;
      team = fonctions['equipe'] as String?;
    }

    // Récupérer les réseaux sociaux (si disponible directement)
    String? facebook, linkedin, twitter, instagram;
    final social = json['social'];
    if (social is Map) {
      facebook = social['facebook'] as String?;
      linkedin = social['linkedin'] as String?;
      twitter = social['twitter'] as String?;
      instagram = social['instagram'] as String?;
    }

    // Si pas de réseaux sociaux directs, essayer de les extraire de la description
    final description = json['excerpt'] as String? ?? json['description'] as String?;
    if (description != null && description.isNotEmpty) {
      facebook = facebook ?? _extractSocialLink(description, 'facebook');
      linkedin = linkedin ?? _extractSocialLink(description, 'linkedin');
      twitter = twitter ?? _extractSocialLink(description, 'twitter');
      instagram = instagram ?? _extractSocialLink(description, 'instagram');
    }

    print(
      '[DEBUG] Réseaux: FB=$facebook, LI=$linkedin, TW=$twitter, IG=$instagram',
    );

    return TeamMember(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      role: role,
      team: team,
      photoUrl: photo,
      facebook: facebook,
      linkedin: linkedin,
      twitter: twitter,
      instagram: instagram,
      description: description,
    );
  }

  /// Extraire un lien de réseau social depuis la description
  /// Format attendu: "facebook: https://facebook.com/..." ou "facebook:https://facebook.com/..."
  static String? _extractSocialLink(String description, String platform) {
    try {
      final pattern = RegExp(
        '${platform}\\s*:\\s*(https?://[^\\s]+)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(description);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    } catch (e) {
      print('[DEBUG] Erreur extraction $platform: $e');
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'team': team,
    'photoUrl': photoUrl,
    'facebook': facebook,
    'linkedin': linkedin,
    'twitter': twitter,
    'instagram': instagram,
    'description': description,
  };

  // Simple mock list for development/testing
  static List<TeamMember> mocks() => [
    TeamMember(
      id: '1',
      name: 'Aminata Diallo',
      role: 'Directrice des Programmes',
      team: 'Direction',
      photoUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
      linkedin: 'https://www.linkedin.com/in/aminata-diallo',
      twitter: 'https://twitter.com/aminata',
      facebook: 'https://facebook.com/aminata.diallo',
      instagram: 'https://instagram.com/aminata',
      description:
          'Aminata dirige les programmes de participation citoyenne et veille à l\'impact local des projets.',
    ),
    TeamMember(
      id: '2',
      name: 'Mamoudou Keita',
      role: 'Responsable Technique',
      team: 'Tech',
      photoUrl:
          'https://images.unsplash.com/photo-1545996124-1b8b9d7e3c5b?w=800&q=80',
      linkedin: 'https://www.linkedin.com/in/mamoudou-keita',
      instagram: 'https://instagram.com/mamoudou',
      description:
          'Mamoudou coordonne les développements techniques et l\'architecture des plateformes.',
    ),
    TeamMember(
      id: '3',
      name: 'Fatoumata Camara',
      role: 'Chargée de Communication',
      team: 'Communication',
      photoUrl:
          'https://images.unsplash.com/photo-1531123414780-f0b5f61f5b66?w=800&q=80',
      twitter: 'https://twitter.com/fatou_camara',
      facebook: 'https://facebook.com/fatou.camara',
      description:
          'Fatoumata conçoit les campagnes de sensibilisation et gère les relations publiques.',
    ),
    TeamMember(
      id: '4',
      name: 'Ibrahima Sylla',
      role: 'Analyste Données',
      team: 'Recherche',
      photoUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=800&q=80',
      linkedin: 'https://www.linkedin.com/in/ibrahima-sylla',
      description:
          'Ibrahima analyse les données publiques pour produire des indicateurs de transparence.',
    ),
    TeamMember(
      id: '5',
      name: 'Seynabou Bah',
      role: 'Responsable Projets Locaux',
      team: 'Terrain',
      photoUrl:
          'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=800&q=80',
      facebook: 'https://facebook.com/seynabou.bah',
      instagram: 'https://instagram.com/seynabou',
      description:
          'Seynabou supervise les projets locaux et coordonne les équipes sur le terrain.',
    ),
  ];
}
