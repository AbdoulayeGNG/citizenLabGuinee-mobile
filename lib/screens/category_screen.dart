import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../repositories/document_repository.dart';
import '../screens/document_viewer_screen.dart';
import '../services/api_service.dart';
import '../widgets/download_button.dart';

class CategoryScreen extends StatefulWidget {
  final String categorySlug;

  const CategoryScreen({super.key, required this.categorySlug});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Post>> _postsFuture;
  final DocumentRepository _repo = DocumentRepository();

  @override
  void initState() {
    super.initState();
    _postsFuture = Provider.of<ApiService>(
      context,
      listen: false,
    ).fetchPostsByCategory(widget.categorySlug);
  }

  String _stripHtml(String text) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return text.replaceAll(regex, '').trim();
  }

  Future<void> _openDocument(String id, String title) async {
    final doc = await _repo.getById(id);
    if (doc != null &&
        doc.localPath != null &&
        File(doc.localPath!).existsSync()) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DocumentViewerScreen(localPath: doc.localPath!, title: title),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document non trouvé en local. Téléchargez-le d’abord.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur lors du chargement'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _postsFuture = Provider.of<ApiService>(
                          context,
                          listen: false,
                        ).fetchPostsByCategory(widget.categorySlug);
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun article trouvé dans cette catégorie'),
            );
          }

          final posts = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Hero section
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.categorySlug.replaceAll('-', ' ')),
                  centerTitle: true,
                ),
              ),

              // Liste des articles
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/article',
                          arguments: {'id': post.slug},
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: Image.network(
                                  post.imageUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _stripHtml(post.title),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _stripHtml(post.excerpt ?? ''),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      post.date,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                    if (post.documentUrl != null) ...[
                                      const SizedBox(height: 12),
                                      FutureBuilder<bool>(
                                        future: _repo.isDownloaded(post.id),
                                        builder: (context, snapshot) {
                                          final downloaded =
                                              snapshot.data == true;
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: DownloadButton(
                                                  id: post.id,
                                                  title: post.title,
                                                  remoteUrl: post.documentUrl!,
                                                  onDownloaded: () =>
                                                      setState(() {}),
                                                ),
                                              ),
                                              if (downloaded)
                                                const SizedBox(width: 12),
                                              if (downloaded)
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _openDocument(
                                                          post.id,
                                                          post.title,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.open_in_new,
                                                    ),
                                                    label: const Text('Ouvrir'),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: posts.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
