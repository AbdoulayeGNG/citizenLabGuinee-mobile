import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CitizenLab Guinée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: apiService.refreshData,
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
                  // Hero Section (hauteur réduite)
                /*   Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.public, size: 44, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Bienvenue sur CitizenLab Guinée',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), */

                  // Dernières actualités
                  const SectionHeader(title: 'Actualités'),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: apiService.posts.length,
                      itemBuilder: (context, index) {
                        final post = apiService.posts[index];
                        return PostCard(post: post);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Podcast
                  const SectionHeader(title: 'Podcasts recents'),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: apiService.posts.length > 6
                          ? 6
                          : apiService.posts.length,
                      itemBuilder: (context, index) {
                        final post = apiService.posts[index];
                        return PostCard(post: post);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Accès rapides (2x2)
                  const SectionHeader(title: 'Accès rapides'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _QuickAccessCard(
                          icon: Icons.work_outline,
                          title: 'Projets',
                          onTap: () =>
                              Navigator.pushNamed(context, '/projects'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.event,
                          title: 'Événements',
                          onTap: () => Navigator.pushNamed(context, '/events'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.group_outlined,
                          title: 'Communauté',
                          onTap: () =>
                              Navigator.pushNamed(context, '/community'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.description_outlined,
                          title: 'Documents',
                          onTap: () =>
                              Navigator.pushNamed(context, '/documents'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
