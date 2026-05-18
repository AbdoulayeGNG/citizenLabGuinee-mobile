import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../repositories/document_repository.dart';
import '../screens/document_viewer_screen.dart';
import '../services/api_service.dart';
import '../widgets/download_button.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<Post>> _documentsFuture;
  final DocumentRepository _repo = DocumentRepository();

  @override
  void initState() {
    super.initState();
    _documentsFuture = Provider.of<ApiService>(
      context,
      listen: false,
    ).fetchPostsByCategory('documents');
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
      appBar: AppBar(title: const Text('Documents'), elevation: 0),
      body: FutureBuilder<List<Post>>(
        future: _documentsFuture,
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
                  const Text('Erreur lors du chargement des documents'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _documentsFuture = Provider.of<ApiService>(
                          context,
                          listen: false,
                        ).fetchPostsByCategory('documents');
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final documents = snapshot.data ?? [];
          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('Aucun document disponible'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final post = documents[index];
              return _buildDocumentCard(context, post);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, Post post) {
    final documentUrl = post.documentUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stripHtml(post.title),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (documentUrl == null)
              Text(
                'Aucun fichier document détecté dans ce post.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            if (documentUrl != null)
              FutureBuilder<bool>(
                future: _repo.isDownloaded(post.id),
                builder: (context, snapshot) {
                  final downloaded = snapshot.data == true;
                  return Row(
                    children: [
                      Expanded(
                        child: DownloadButton(
                          id: post.id,
                          title: post.title,
                          remoteUrl: documentUrl,
                          onDownloaded: () => setState(() {}),
                        ),
                      ),
                      if (downloaded) const SizedBox(width: 12),
                      if (downloaded)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openDocument(post.id, post.title),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Ouvrir'),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
