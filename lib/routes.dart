import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/article_screen.dart';
import 'screens/category_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/search_screen.dart';
import 'screens/events_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/offline_test_screen.dart';
import 'screens/projects_page.dart';
import 'screens/about_screen.dart';
import 'screens/news_list_screen.dart';
import 'screens/podcasts_list_screen.dart';
import 'screens/community_screen.dart';
import 'models/post.dart';

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
  static const String about = '/about';
  static const String news = '/news';
  static const String podcasts = '/podcasts';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case article:
        final args = settings.arguments;
        String? articleId;

        // Handle Post object
        if (args is Post) {
          articleId = args.slug;
        }
        // Handle Map with id or slug
        else if (args is Map<String, dynamic>) {
          articleId = (args['id'] ?? args['slug']) as String?;
        }

        if (articleId == null || articleId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: const Center(child: Text('ID d\'article manquant')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ArticleScreen(articleId: articleId ?? ''),
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

      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case projects:
        return MaterialPageRoute(builder: (_) => const ProjectsPage());

      case events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());

      case community:
        return MaterialPageRoute(builder: (_) => const CommunityScreen());

      case documents:
        return MaterialPageRoute(builder: (_) => const DocumentsScreen());

      case offlineTest:
        return MaterialPageRoute(builder: (_) => const OfflineTestScreen());

      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case news:
        return MaterialPageRoute(builder: (_) => const NewsListScreen());

      case podcasts:
        return MaterialPageRoute(builder: (_) => const PodcastsListScreen());

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
