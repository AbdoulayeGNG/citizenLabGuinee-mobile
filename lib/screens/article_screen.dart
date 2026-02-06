import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class ArticleScreen extends StatelessWidget {
  final String articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post?>(
      future: Provider.of<ApiService>(
        context,
        listen: false,
      ).fetchPostById(articleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Article')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Article')),
            body: const Center(child: Text('Article introuvable')),
          );
        }

        final article = snapshot.data!;
        final apiService = Provider.of<ApiService>(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Article'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareArticle(context, article),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image en vedette
                if (article.imageUrl != null)
                  Image.network(
                    article.imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),

                      // Métadonnées (auteur, date, catégories)
                      Row(
                        children: [
                          if (article.authorName != null)
                            Text(
                              'Par ${article.authorName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                              'fr_FR',
                            ).format(DateTime.parse(article.date)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Catégories
                      if (article.categories != null &&
                          article.categories!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: article.categories!
                              .map(
                                (category) => Chip(
                                  label: Text(category),
                                  onDeleted: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/category',
                                      arguments: {'slug': category},
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Contenu HTML
                      Text(
                        article.excerpt ?? article.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      // Note: Pour un vrai HTML rendering, utiliser flutter_html package
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Articles connexes
                if (apiService.posts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Articles connexes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: apiService.posts.length > 3
                                ? 3
                                : apiService.posts.length,
                            itemBuilder: (context, index) {
                              return PostCard(post: apiService.posts[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareArticle(BuildContext context, Post article) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager via...'),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('WhatsApp'),
              onTap: () {
                // Implémenter le partage WhatsApp
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Facebook'),
              onTap: () {
                // Implémenter le partage Facebook
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
