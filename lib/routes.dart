import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/article_screen.dart';
import 'screens/category_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/team_screen.dart';
import 'screens/search_screen.dart';
import 'screens/events_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/offline_test_screen.dart';
import 'screens/projects_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String article = '/article';
  static const String category = '/category';
  static const String categories = '/categories';
  static const String team = '/team';
  static const String search = '/search';
  static const String projects = '/projects';
  static const String events = '/events';
  static const String community = '/community';
  static const String documents = '/documents';
  static const String offlineTest = '/offline-test';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case article:
        final args = settings.arguments as Map<String, dynamic>?;
        final articleId = args?['id'] as String?;
        if (articleId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: const Center(child: Text('ID d\'article manquant')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ArticleScreen(articleId: articleId),
        );

      case category:
        final args = settings.arguments as Map<String, dynamic>?;
        final categorySlug = args?['slug'] as String?;
        if (categorySlug == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: const Center(child: Text('Slug de catégorie manquant')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CategoryScreen(categorySlug: categorySlug),
        );

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case team:
        return MaterialPageRoute(builder: (_) => const TeamScreen());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case projects:
        return MaterialPageRoute(builder: (_) => const ProjectsPage());

      case events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());

      case community:
        return MaterialPageRoute(builder: (_) => const TeamScreen());

      case documents:
        return MaterialPageRoute(builder: (_) => const DocumentsScreen());

      case offlineTest:
        return MaterialPageRoute(builder: (_) => const OfflineTestScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(child: Text('Route non trouvée: ${settings.name}')),
          ),
        );
    }
  }
}
