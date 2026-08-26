import 'package:flutter/material.dart';
import '../models/downloaded_document.dart';
import '../repositories/document_repository.dart';
import '../services/download_service.dart';

class DownloadButton extends StatefulWidget {
  final String id;
  final String title;
  final String remoteUrl;
  final VoidCallback? onDownloaded;

  const DownloadButton({
    super.key,
    required this.id,
    required this.title,
    required this.remoteUrl,
    this.onDownloaded,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;
  int _progress = 0;

  late final DocumentRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = DocumentRepository(downloadService: DownloadService());
  }

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });
    final doc = DownloadedDocument(
      id: widget.id,
      title: widget.title,
      remoteUrl: widget.remoteUrl,
      localPath: null,
      downloadedAt: DateTime.now(),
    );

    try {
      await _repo.downloadDocument(doc, (sent, total) {
        if (total > 0) {
          final p = ((sent / total) * 100).round();
          setState(() {
            _progress = p;
          });
        }
      });

      setState(() {
        _isDownloading = false;
        _progress = 100;
      });

      widget.onDownloaded?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Téléchargement terminé : ${widget.title}')),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _progress = 0;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur téléchargement: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isDownloading ? null : _handleDownload,
      icon: _isDownloading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: Text(
        _isDownloading ? 'Téléchargement ($_progress%)' : 'Télécharger',
      ),
    );
  }
}
