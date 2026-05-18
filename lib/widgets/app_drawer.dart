import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final videoCategories = apiService.categories.where((category) {
      final displayName = category.displayName.toLowerCase();
      final slug = category.slug.toLowerCase();
      return displayName.contains('video') ||
          displayName.contains('vidéo') ||
          slug.contains('video') ||
          slug.contains('vidéo');
    }).toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF009460)),
            child: Text(
              'CitizenLab Guinée',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildSection('Navigation', [
            _buildMenuItem(context, 'Accueil', Icons.home, '/'),
            _buildMenuItem(context, 'Actualités', Icons.newspaper, '/news'),
            _buildMenuItem(context, 'Projets', Icons.work_outline, '/projects'),
            _buildMenuItem(
              context,
              'Formations',
              Icons.school_outlined,
              '/formations',
            ),
            _buildMenuItem(
              context,
              'Documents',
              Icons.description_outlined,
              '/documents',
            ),
            _buildMenuItem(context, 'Équipe', Icons.people, '/community'),
          ]),
          if (videoCategories.isNotEmpty) ...[
            const Divider(),
            _buildSection('Catégories', [
              ...videoCategories.map((category) {
                return _buildCategoryMenuItem(
                  context,
                  category.displayName,
                  category.slug,
                );
              }).toList(),
            ]),
          ],
          const Divider(),
          _buildSection('À propos', [
            _buildMenuItem(context, 'Qui sommes-nous', Icons.info, '/about'),
          ]),
        ],
      ),
    );
  }

  static Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        ...items,
      ],
    );
  }

  static ListTile _buildMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    String? route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (route != null && route != '/') {
          Navigator.pushNamed(context, route);
        } else if (route == '/') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
    );
  }

  static ListTile _buildCategoryMenuItem(
    BuildContext context,
    String label,
    String slug,
  ) {
    return ListTile(
      leading: const Icon(Icons.category),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/category',
          arguments: {'slug': slug, 'name': label},
        );
      },
    );
  }
}
