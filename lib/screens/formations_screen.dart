import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

String _stripHtml(String htmlString) {
  final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
  return htmlString.replaceAll(exp, '').trim();
}

class FormationsScreen extends StatelessWidget {
  const FormationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    // Filter posts by "formations" category
    final events = apiService.posts
        .where(
          (post) =>
              post.categories?.any(
                (cat) => cat.toLowerCase().contains('formations'),
              ) ??
              false,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Formations'), elevation: 0),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune formation disponible',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/article', arguments: event);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event image
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: (event.imageUrl?.isNotEmpty ?? false)
                                ? Image.network(
                                    event.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image_not_supported,
                                      );
                                    },
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                        ),
                        // Event info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _stripHtml(event.title),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _stripHtml(
                                  event.excerpt ?? 'Description indisponible',
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
