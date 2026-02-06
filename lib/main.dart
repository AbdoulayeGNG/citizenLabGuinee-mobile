import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/hive_post.dart';
import 'models/hive_category.dart';
import 'models/hive_team_member.dart';
import 'models/downloaded_document.dart';
import 'services/api_service.dart';
import 'theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register manual adapters so Hive can store typed objects
  Hive.registerAdapter(HivePostAdapter());
  Hive.registerAdapter(HiveCategoryAdapter());
  Hive.registerAdapter(HiveTeamMemberAdapter());
  // Register document adapter
  Hive.registerAdapter(DownloadedDocumentAdapter());

  // Open Hive boxes with correct types
  await Hive.openBox<HivePost>('postsBox');
  await Hive.openBox<HiveCategory>('categoriesBox');
  await Hive.openBox<HiveTeamMember>('teamsBox');
  await Hive.openBox<DownloadedDocument>('documentsBox');
  await Hive.openBox('metadataBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = ApiService();
        // Start initialization in background without blocking UI
        service.init();
        return service;
      },
      child: MaterialApp(
        title: 'CitizenLab Guinée',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
