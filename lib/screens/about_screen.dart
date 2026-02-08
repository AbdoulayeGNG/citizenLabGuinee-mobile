import 'package:flutter/material.dart';
import '../theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Couleurs du drapeau guinéen
  static const Color guineeRed = Color(0xFFDC143C);
  static const Color guineeYellow = Color(0xFFFCD116);
  static const Color guineeGreen = Color(0xFF007A5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // 1️⃣ HERO / QUI SOMMES-NOUS
              _buildHeroSection(context),
              const SizedBox(height: 40),

              // 2️⃣ NOTRE MISSION
              _buildMissionSection(context),
              const SizedBox(height: 40),

              // 3️⃣ NOS AXES D'INTERVENTION
              _buildAxisSection(context),
              const SizedBox(height: 40),

              // 4️⃣ NOS VALEURS
              _buildValuesSection(context),
              const SizedBox(height: 40),

              // 5️⃣ CALL TO ACTION
              _buildCTASection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar personnalisée
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'À propos de nous',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  // 1️⃣ HERO SECTION
  Widget _buildHeroSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              guineeGreen.withOpacity(0.05),
              guineeYellow.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: guineeGreen.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Badge amélioré
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: guineeRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: guineeRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined, size: 14, color: guineeRed),
                    const SizedBox(width: 6),
                    Text(
                      'QUI NOUS SOMMES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: guineeRed,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logo premium
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [guineeGreen, guineeYellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: guineeGreen.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.hub_outlined,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                'CitizenLab Guinée',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),

              // Texte descriptif
              Text(
                'Un laboratoire d\'innovation et d\'engagement civique dédié à transformer la Guinée par le numérique, en renforçant la participation citoyenne et en promouvant une gouvernance ouverte et inclusive.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.7,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2️⃣ MISSION SECTION
  Widget _buildMissionSection(BuildContext context) {
    return Column(
      children: [
        // Titre de section
        Text(
          'Notre Mission',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 20),

        // Mission card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [guineeYellow.withOpacity(0.12), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: guineeYellow.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [guineeGreen, guineeYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: guineeGreen.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lightbulb,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    'Transformer par le numérique',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checklist
                  _buildChecklistItem(
                    context,
                    'Renforcer la participation citoyenne',
                  ),
                  const SizedBox(height: 14),
                  _buildChecklistItem(context, 'Former des jeunes leaders'),
                  const SizedBox(height: 14),
                  _buildChecklistItem(
                    context,
                    'Promouvoir l\'innovation civique',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(BuildContext context, String text) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: guineeGreen,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: guineeGreen.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
              weight: 800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 3️⃣ AXES D'INTERVENTION SECTION
  Widget _buildAxisSection(BuildContext context) {
    final axes = [
      {
        'number': '01',
        'title': 'Education et usage rationnel du numérique',
        'subtitle': 'Former et sensibiliser la population',
        'icon': Icons.school_outlined,
      },
      {
        'number': '02',
        'title': 'Gouvernance et innovation technologique',
        'subtitle': 'Promouvoir une gouvernance ouverte',
        'icon': Icons.how_to_vote_outlined,
      },
      {
        'number': '03',
        'title': 'Accompagnement des projets technologiques des jeunes',
        'subtitle': 'Soutenir l\'entrepreneuriat jeune',
        'icon': Icons.rocket_launch_outlined,
      },
    ];

    return Column(
      children: [
        // Titre de section
        Text(
          'Nos Axes d\'Intervention',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),

        // Cartes
        ...List.generate(
          axes.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAxisCard(context, axes[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildAxisCard(
    BuildContext context,
    Map<String, dynamic> axis,
    int index,
  ) {
    final colors = [guineeGreen, guineeYellow, guineeRed];
    final dominantColor = colors[index % colors.length];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [dominantColor.withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numéro + Icône
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: dominantColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(axis['icon'], color: dominantColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    axis['number'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dominantColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Titre
              Text(
                axis['title'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                axis['subtitle'],
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4️⃣ VALUES SECTION
  Widget _buildValuesSection(BuildContext context) {
    final values = [
      {
        'title': 'Inclusion',
        'description':
            'Nous croyons que chacun a une voix qui mérite d\'être entendue.',
      },
      {
        'title': 'Transparence',
        'description':
            'La clarté et l\'honnêteté sont les fondations de notre travail.',
      },
      {
        'title': 'Collaboration',
        'description': 'Ensemble, nous accomplissons plus que seuls.',
      },
      {
        'title': 'Innovation',
        'description': 'Nous explorons continuellement de nouvelles solutions.',
      },
      {
        'title': 'Engagement Citoyen',
        'description':
            'Nous mobilisons les citoyens pour un changement positif.',
      },
    ];

    return Column(
      children: [
        // Titre de section
        Text(
          'Nos Valeurs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),

        // Valeurs
        ...List.generate(
          values.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildValueCard(context, values[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(
    BuildContext context,
    Map<String, String> value,
    int index,
  ) {
    final colors = [
      guineeGreen,
      guineeYellow,
      guineeRed,
      guineeGreen,
      guineeYellow,
    ];
    final dominantColor = colors[index % colors.length];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Numéro/Indicateur
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dominantColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value['title']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value['description']!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5️⃣ CALL TO ACTION SECTION
  Widget _buildCTASection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [guineeGreen, guineeYellow, guineeRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Titre
              Text(
                'Rejoignez le mouvement',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Sous-titre
              Text(
                'Ensemble, construisons une Guinée numérique inclusive, transparente et participative',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: guineeRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _handleContactPress(context),
                  child: Text(
                    'Nous contacter',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: guineeRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gérer le clic sur "Nous contacter"
  Future<void> _handleContactPress(BuildContext context) async {
    // Vous pouvez naviguer vers une page Contact ou ouvrir un email
    // Pour l'instant, afficher un dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nous contacter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: info@citizenlabguinee.org',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Téléphone: +224 XXX XXX XXX',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Adresse: Conakry, Guinée',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
