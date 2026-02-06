import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Mock documents data
  final List<MockDocument> mockDocuments = [
    MockDocument(
      id: '1',
      title: 'Rapport Annuel 2025',
      fileName: 'rapport_annuel_2025.pdf',
      size: '2.5 MB',
      uploadDate: '15 janvier 2026',
      isDownloaded: true,
      downloadUrl: 'https://example.com/rapport_2025.pdf',
    ),
    MockDocument(
      id: '2',
      title: 'Guide d\'Utilisation',
      fileName: 'guide_utilisation.pdf',
      size: '1.8 MB',
      uploadDate: '10 janvier 2026',
      isDownloaded: false,
      downloadUrl: 'https://example.com/guide.pdf',
    ),
    MockDocument(
      id: '3',
      title: 'Politique de Confidentialité',
      fileName: 'politique_confidentialite.pdf',
      size: '0.8 MB',
      uploadDate: '05 janvier 2026',
      isDownloaded: true,
      downloadUrl: 'https://example.com/politique.pdf',
    ),
    MockDocument(
      id: '4',
      title: 'Conditions d\'Utilisation',
      fileName: 'conditions_utilisation.pdf',
      size: '1.2 MB',
      uploadDate: '01 janvier 2026',
      isDownloaded: false,
      downloadUrl: 'https://example.com/conditions.pdf',
    ),
    MockDocument(
      id: '5',
      title: 'Présentation du Projet',
      fileName: 'presentation_projet.pdf',
      size: '3.1 MB',
      uploadDate: '28 décembre 2025',
      isDownloaded: true,
      downloadUrl: 'https://example.com/presentation.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents'), elevation: 0),
      body: _buildDocumentList(context),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    if (mockDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun document disponible',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockDocuments.length,
      itemBuilder: (context, index) {
        final document = mockDocuments[index];
        return _buildDocumentCard(context, document);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, MockDocument doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document title and info
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
                        doc.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${doc.size} • ${doc.uploadDate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Download indicator
                if (doc.isDownloaded)
                  Chip(
                    label: const Text('Téléchargé'),
                    backgroundColor: Colors.green[100],
                    labelStyle: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (doc.isDownloaded)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ouverture de ${doc.title}...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ouvrir'),
                    ),
                  ),
                if (doc.isDownloaded) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            doc.isDownloaded
                                ? 'Suppression de ${doc.title}...'
                                : 'Téléchargement de ${doc.title}...',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      doc.isDownloaded ? Icons.delete : Icons.download,
                    ),
                    label: Text(doc.isDownloaded ? 'Supprimer' : 'Télécharger'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mock document model
class MockDocument {
  final String id;
  final String title;
  final String fileName;
  final String size;
  final String uploadDate;
  bool isDownloaded;
  final String downloadUrl;

  MockDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.size,
    required this.uploadDate,
    required this.isDownloaded,
    required this.downloadUrl,
  });
}
