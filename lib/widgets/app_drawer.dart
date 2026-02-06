import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildMenuItem(
              context,
              'Catégories',
              Icons.category,
              '/categories',
            ),
            _buildMenuItem(context, 'Équipe', Icons.people, '/team'),
            _buildMenuItem(context, 'Recherche', Icons.search, '/search'),
          ]),
          const Divider(),
          _buildSection('À propos', [
            _buildMenuItem(context, 'Qui sommes-nous', Icons.info, '/about'),
          ]),
          const Divider(),
          _buildSection('Debug', [
            _buildMenuItem(
              context,
              'Test Mode Offline',
              Icons.wifi_off,
              '/offline-test',
            ),
          ]),
          const Divider(),
          _buildMenuItem(context, 'Réglages', Icons.settings, null),
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
}
