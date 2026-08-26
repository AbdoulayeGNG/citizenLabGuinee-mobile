import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/post_card.dart';
import '../models/project.dart';
import '../utils/responsive.dart';
import '../theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('CitizenLab Guinée'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: apiService.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: apiService.isLoading ? null : apiService.refreshData,
          ),
          if (apiService.isOffline)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.wifi_off, color: Colors.yellow),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: apiService.posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ Hero Institutionnel
                  const _HeroSection(),

                  // 2️⃣ Section "Qui sommes-nous ?"
                  const _AboutSection(),

                  // 3️⃣ Accès rapides (Grid 2x2)
                  const _QuickAccessSection(),

                  // 4️⃣ Projets en aperçu (max 3)
                  const _ProjectsPreviewSection(),

                  // 5️⃣ Actualités (max 3)
                  _NewsPreviewSection(apiService: apiService),

                  // 6️⃣ Podcasts récents (max 3)
                  _PodcastPreviewSection(apiService: apiService),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ============================================================================
// 1️⃣ HERO SECTION - Gradient rouge → vert
// ============================================================================
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCE1126), // Rouge
            Color(0xFF009460), // Vert
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Icon(Icons.public, size: 36, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 12),
          // Titre principal
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'CitizenLab Guinée',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sous-titre/citation
          Text(
            'Renforcer la participation citoyenne et l\'engagement démocratique en Guinée.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2️⃣ ABOUT SECTION - "Qui sommes-nous ?"
// ============================================================================
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Qui sommes-nous ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Texte institutionnel
          Text(
            'CitizenLab est une plateforme citoyenne qui œuvre à renforcer '
            'la démocratie participative et la gouvernance transparente. '
            'Nous facilitons l\'engagement des citoyens guinéens dans les '
            'décisions qui les concernent.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // Bouton "En savoir plus"
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('En savoir plus'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3️⃣ QUICK ACCESS SECTION - Grid 2x2
// ============================================================================
class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Accès rapides',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Grid adaptatif (2 colonnes mobile, 4 tablette)
          GridView.count(
            crossAxisCount: Responsive.getGridColumns(
              context,
              mobile: 2,
              tablet: 4,
              largeTablet: 4,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: Responsive.isMobile(context) ? 1.5 : 2.0,
            children: [
              _QuickAccessCard(
                icon: Icons.work_outline,
                title: 'Projets',
                onTap: () => Navigator.pushNamed(context, '/projects'),
              ),
              _QuickAccessCard(
                icon: Icons.event,
                title: 'Formations',
                onTap: () => Navigator.pushNamed(context, '/formations'),
              ),
              _QuickAccessCard(
                icon: Icons.group_outlined,
                title: 'Communauté',
                onTap: () => Navigator.pushNamed(context, '/community'),
              ),
              _QuickAccessCard(
                icon: Icons.description_outlined,
                title: 'Documents',
                onTap: () => Navigator.pushNamed(context, '/documents'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4️⃣ PROJECTS PREVIEW SECTION - Max 3 projets
// ============================================================================
class _ProjectsPreviewSection extends StatelessWidget {
  const _ProjectsPreviewSection();

  @override
  Widget build(BuildContext context) {
    final projects = ProjectCategory.projects.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et "Voir tout"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nos projets',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/projects'),
                child: const Text('Voir tout', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Liste verticale compacte
          ...projects.map((project) => _CompactProjectCard(project: project)),
        ],
      ),
    );
  }
}

// ============================================================================
// 5️⃣ NEWS PREVIEW SECTION - Max 3 actualités
// ============================================================================
class _NewsPreviewSection extends StatelessWidget {
  final ApiService apiService;

  const _NewsPreviewSection({required this.apiService});

  @override
  Widget build(BuildContext context) {
    final newsList = apiService.posts
        .where(
          (post) =>
              post.categories?.any(
                (cat) => cat.toLowerCase().contains('actualit'),
              ) ??
              false,
        )
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et "Voir tout"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actualités',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/news'),
                child: const Text('Voir tout', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Scroll horizontal avec LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = Responsive.isMobile(context)
                  ? Responsive.width(context) * 0.6
                  : Responsive.width(context) * 0.3;
              final totalHeight =
                  (cardWidth * 0.45) + 80; // imageHeight + texte padding
              return SizedBox(
                height: totalHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final post = newsList[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == newsList.length - 1 ? 0 : 12,
                      ),
                      child: PostCard(
                        post: post,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/article',
                          arguments: {'id': post.slug},
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6️⃣ PODCAST PREVIEW SECTION - Max 3 podcasts
// ============================================================================
class _PodcastPreviewSection extends StatelessWidget {
  final ApiService apiService;

  const _PodcastPreviewSection({required this.apiService});

  @override
  Widget build(BuildContext context) {
    final podcastList = apiService.posts
        .where(
          (post) =>
              post.categories?.any(
                (cat) => cat.toLowerCase().contains('podcast'),
              ) ??
              false,
        )
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et "Voir tout"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Podcasts récents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/podcasts'),
                child: const Text('Voir tout', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Scroll horizontal adaptatif
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = Responsive.isMobile(context)
                  ? Responsive.width(context) * 0.6
                  : Responsive.width(context) * 0.3;
              final totalHeight = (cardWidth * 0.45) + 80;
              return SizedBox(
                height: totalHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: podcastList.length,
                  itemBuilder: (context, index) {
                    final post = podcastList[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == podcastList.length - 1 ? 0 : 12,
                      ),
                      child: PostCard(
                        post: post,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/article',
                          arguments: {'id': post.slug},
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

/// Carte d'accès rapide (Grid item)
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte projet compacte (pour aperçu)
class _CompactProjectCard extends StatelessWidget {
  final ProjectCategory project;

  const _CompactProjectCard({required this.project});

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colorAccent = _getColorFromHex(project.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/projects'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icone compacte avec fallback
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorAccent.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    project.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.themes.isNotEmpty ? project.themes.first : '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
