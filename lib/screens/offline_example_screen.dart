import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../repositories/posts_repository.dart';
import '../repositories/categories_repository.dart';

/// Example screen demonstrating offline-first usage with Hive repositories
class OfflineExampleScreen extends StatefulWidget {
  const OfflineExampleScreen({super.key});

  @override
  State<OfflineExampleScreen> createState() => _OfflineExampleScreenState();
}

class _OfflineExampleScreenState extends State<OfflineExampleScreen> {
  final PostsRepository _postsRepo = PostsRepository();
  final CategoriesRepository _categoriesRepo = CategoriesRepository();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showCacheInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple: Fonctionnalités Hive'),
        actions: [
          // Toggle offline info
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              setState(() => _showCacheInfo = !_showCacheInfo);
            },
          ),
          // Manual refresh
          Consumer<ApiService>(
            builder: (context, apiService, _) {
              return IconButton(
                icon: Icon(
                  apiService.isLoading ? Icons.hourglass_empty : Icons.refresh,
                ),
                onPressed: apiService.isLoading
                    ? null
                    : () => apiService.refreshData(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show offline status and cache info
          Consumer<ApiService>(
            builder: (context, apiService, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Offline indicator
                    if (apiService.isOffline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off, color: Colors.amber[900]),
                            const SizedBox(width: 8),
                            Text(
                              'Mode hors ligne - Données en cache',
                              style: TextStyle(
                                color: Colors.amber[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Cache info (optional)
                    if (_showCacheInfo) ...[
                      const SizedBox(height: 12),
                      FutureBuilder<DateTime?>(
                        future: _postsRepo.getLastSyncTime(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Aucune mise en cache');
                          }
                          final lastSync = snapshot.data!;
                          final age = DateTime.now().difference(lastSync);
                          return Text(
                            'Mis en cache: ${age.inMinutes}m ago '
                            '(${lastSync.toString().split('.')[0]})',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Chercher dans les articles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Category filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<List>(
              future: _categoriesRepo.getAllCategoriesFromCache(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final categories = snapshot.data!;
                return Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                      },
                    ),
                    ...categories.map((cat) {
                      final slug = cat.slug ?? cat.id;
                      return FilterChip(
                        label: Text(cat.name),
                        selected: _selectedCategory == slug,
                        onSelected: (_) {
                          setState(() => _selectedCategory = slug);
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Posts list (filtered, searchable, offline)
          Expanded(
            child: _searchQuery.isEmpty && _selectedCategory == null
                ? _buildDefaultList()
                : _buildFilteredList(),
          ),
        ],
      ),
    );
  }

  /// Build default posts list from cache
  Widget _buildDefaultList() {
    return Consumer<ApiService>(
      builder: (context, apiService, _) {
        if (apiService.posts.isEmpty) {
          return const Center(
            child: Text('Aucun article en cache. Connectez-vous à Internet.'),
          );
        }
        return ListView.builder(
          itemCount: apiService.posts.length,
          itemBuilder: (context, index) {
            final post = apiService.posts[index];
            return _PostListTile(post: post);
          },
        );
      },
    );
  }

  /// Build filtered/searched posts list
  Widget _buildFilteredList() {
    return FutureBuilder<List>(
      future: _getFilteredPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun résultat trouvé'));
        }
        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PostListTile(post: post);
          },
        );
      },
    );
  }

  /// Get posts based on search and category filter
  Future<List> _getFilteredPosts() async {
    List posts = [];

    if (_selectedCategory != null) {
      posts = await _postsRepo.getPostsByCategory(_selectedCategory!);
    } else {
      posts = await _postsRepo.getAllPostsFromCache();
    }

    if (_searchQuery.isNotEmpty) {
      final searchResults = await _postsRepo.searchPosts(_searchQuery);
      posts = posts
          .where((p) => searchResults.any((sr) => sr.id == p.id))
          .toList();
    }

    return posts;
  }
}

/// Reusable post list tile
class _PostListTile extends StatelessWidget {
  final dynamic post;

  const _PostListTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(post.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              post.excerpt ?? 'Pas de résumé',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            if (post.date != null)
              Text(
                '${post.date!.day}/${post.date!.month}/${post.date!.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ouvert: ${post.title}')));
        },
      ),
    );
  }
}

/// Example: Cache statistics screen
class CacheStatsScreen extends StatelessWidget {
  final PostsRepository _postsRepo = PostsRepository();
  final CategoriesRepository _categoriesRepo = CategoriesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques du cache')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            title: 'Articles en cache',
            future: _postsRepo.getAllPostsFromCache().then((p) => p.length),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Catégories en cache',
            future: _categoriesRepo.getAllCategoriesFromCache().then(
              (c) => c.length,
            ),
          ),
          const SizedBox(height: 16),
          _buildLastSyncCard(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Vider le cache'),
            onPressed: () async {
              await _postsRepo.clearAllPosts();
              await _categoriesRepo.clearAllCategories();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cache vidé')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required Future<int> future}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  '${snapshot.data} éléments',
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dernière synchronisation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<DateTime?>(
              future: _postsRepo.getLastSyncTime(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Jamais synchronisé');
                }
                final sync = snapshot.data!;
                final age = DateTime.now().difference(sync);
                return Text(
                  '${age.inMinutes} minutes ago\n${sync}',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
