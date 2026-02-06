import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../services/api_service.dart';
import '../models/hive_post.dart';
import '../models/hive_category.dart';
import '../models/hive_team_member.dart';

/// Screen de test pour vérifier le fonctionnement du mode offline
class OfflineTestScreen extends StatefulWidget {
  const OfflineTestScreen({super.key});

  @override
  State<OfflineTestScreen> createState() => _OfflineTestScreenState();
}

class _OfflineTestScreenState extends State<OfflineTestScreen> {
  late Box<HivePost> postsBox;
  late Box<HiveCategory> categoriesBox;
  late Box<HiveTeamMember> teamsBox;
  late Box metadataBox;

  @override
  void initState() {
    super.initState();
    postsBox = Hive.box<HivePost>('postsBox');
    categoriesBox = Hive.box<HiveCategory>('categoriesBox');
    teamsBox = Hive.box<HiveTeamMember>('teamsBox');
    metadataBox = Hive.box('metadataBox');
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Future<void> _showBoxContents(BuildContext context, String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Box non ouverte'),
            content: Text(
              boxName == 'cache'
                  ? 'La box legacy "cache" n\'est plus utilisée et n\'est pas ouverte. Les données sont maintenant stockées dans les boxes typées (ex: postsBox).'
                  : 'La box "$boxName" n\'est pas ouverte. Assurez-vous qu\'elle est initialisée dans main().',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final box = Hive.box(boxName);
      final values = box.values.toList();
      print('Box contents for $boxName: ${values.length} items');
      // Format a short preview (max 10 entries)
      final preview = values.take(10).map((v) {
        if (v is Map) return v.toString();
        try {
          // attempt to call toJson if available
          final json = (v as dynamic).toJson();
          return json.toString();
        } catch (_) {
          return v.toString();
        }
      }).toList();

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Contenu de $boxName (${values.length} éléments)'),
          content: SingleChildScrollView(
            child: SelectableText(
              preview.isEmpty ? 'Vide' : preview.join('\n\n'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lecture box $boxName: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode Offline'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            apiService.isOffline
                                ? Icons.wifi_off
                                : Icons.cloud_done,
                            color: apiService.isOffline
                                ? Colors.red
                                : Colors.green,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apiService.isOffline
                                    ? 'Mode Offline'
                                    : 'En ligne',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                apiService.isLoading
                                    ? 'Chargement en cours...'
                                    : 'Prêt',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (apiService.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Erreur: ${apiService.errorMessage}',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cached Data Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résumé du Cache',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildCacheRow(
                        'Articles en cache',
                        postsBox.length,
                        apiService.posts.length,
                      ),

                      _buildCacheRow(
                        'Catégories en cache',
                        categoriesBox.length,
                        apiService.categories.length,
                      ),
                      _buildCacheRow(
                        'Membres équipe en cache',
                        teamsBox.length,
                        apiService.teamMembers.length,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current Data Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Données chargées en mémoire',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildDataSummary(
                        'Articles',
                        apiService.posts.length,
                        apiService.posts.isEmpty
                            ? 'Aucun article en mémoire'
                            : apiService.posts.first.title,
                      ),
                      _buildDataSummary(
                        'Catégories',
                        apiService.categories.length,
                        apiService.categories.isEmpty
                            ? 'Aucune catégorie en mémoire'
                            : apiService.categories.first.name,
                      ),
                      _buildDataSummary(
                        'Équipe',
                        apiService.teamMembers.length,
                        apiService.teamMembers.isEmpty
                            ? 'Aucun membre en mémoire'
                            : apiService.teamMembers.first.name,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Metadata
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Métadonnées',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildMetadataItem(
                        'Dernier sync posts',
                        metadataBox.get('lastSyncTime_posts')?.toString() ??
                            'Jamais',
                      ),
                      _buildMetadataItem(
                        'Durée cache recommandée',
                        metadataBox.get('cacheDuration_posts')?.toString() ??
                            'Non définie',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Test Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions de Test',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Simulate closing and reopening the app
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: const Text(
                                  'Pour tester: fermez l\'app et relancez-la\n'
                                  'Les données mises en cache doivent persister',
                                ),
                              ),
                            );
                          },
                          child: const Text('Test: Fermer et Relancer l\'app'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            apiService.refreshData();
                            _refreshData();
                          },
                          child: const Text('Actualiser les Données'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to home screen
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Retour à l\'accueil'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Debug: Inspect Boxes
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _showBoxContents(context, 'cache');
                              },
                              icon: const Icon(Icons.storage),
                              label: const Text('Voir contenu de cache'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _showBoxContents(context, 'postsBox');
                              },
                              icon: const Icon(Icons.article),
                              label: const Text('Voir contenu de postsBox'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                                // Diagnostic: ask ApiService for repo counts and previews
                                try {
                                  final apiService = Provider.of<ApiService>(context, listen: false);
                                  final counts = await apiService.getCacheCounts();
                                  final previews = await apiService.getCachePreviews(limit: 5);
                                  final postsPreview = previews['posts']!.entries.map((e) => '${e.key}: ${e.value['title'] ?? ''}').join('\n');
                                  final teamsPreview = previews['teams']!.entries.map((e) => '${e.key}: ${e.value['name'] ?? ''}').join('\n');
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Diagnostic Hive'),
                                      content: SingleChildScrollView(
                                        child: SelectableText(
                                          'Counts\nposts: ${counts['posts']}\ncategories: ${counts['categories']}\nteams: ${counts['teams']}\n\nPosts preview:\n${postsPreview.isEmpty ? 'none' : postsPreview}\n\nTeams preview:\n${teamsPreview.isEmpty ? 'none' : teamsPreview}',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur diagnostic: $e')),
                                  );
                                }
                          },
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Vérifier cache Hive'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheRow(String label, int hiveCount, int memoryCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Cache: $hiveCount',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mémoire: $memoryCount',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary(String label, int count, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: count > 0
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count éléments',
                  style: TextStyle(
                    fontSize: 12,
                    color: count > 0
                        ? Colors.green.shade900
                        : Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
