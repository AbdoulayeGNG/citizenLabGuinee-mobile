import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/post.dart';

class PodcastsListScreen extends StatelessWidget {
  const PodcastsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final posts = api.posts; // Assuming podcasts are represented as posts

    return Scaffold(
      appBar: AppBar(title: const Text('Podcasts')),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final Post post = posts[index];
                return ListTile(
                  leading: post.imageUrl != null
                      ? Image.network(
                          post.imageUrl!,
                          width: 72,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.podcasts),
                  title: Text(post.title),
                  subtitle: Text(post.date),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/article',
                    arguments: {'id': post.slug},
                  ),
                );
              },
            ),
    );
  }
}
