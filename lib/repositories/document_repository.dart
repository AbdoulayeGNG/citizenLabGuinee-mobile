import 'dart:io';
import 'package:hive/hive.dart';
import '../models/downloaded_document.dart';
import '../services/download_service.dart';

class DocumentRepository {
  static const String _boxName = 'documentsBox';
  static const String _lastSyncKey = 'documents_last_sync';

  final DownloadService _downloadService;

  DocumentRepository({DownloadService? downloadService})
    : _downloadService = downloadService ?? DownloadService();

  Box<DownloadedDocument> get _box => Hive.box<DownloadedDocument>(_boxName);
  Box get _metadataBox => Hive.box('metadataBox');

  Future<List<DownloadedDocument>> getAllDocuments() async {
    try {
      return _box.values.toList();
    } catch (e) {
      print('DocumentRepository.getAllDocuments error: $e');
      return [];
    }
  }

  Future<DownloadedDocument?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      print('DocumentRepository.getById error: $e');
      return null;
    }
  }

  Future<bool> isDownloaded(String id) async {
    final doc = await getById(id);
    if (doc == null) return false;
    if (doc.localPath == null) return false;
    final f = File(doc.localPath!);
    return f.existsSync();
  }

  /// Download a document and save metadata (Hive only). Returns updated DownloadedDocument with localPath.
  Future<DownloadedDocument> downloadDocument(
    DownloadedDocument doc,
    void Function(int sent, int total)? onProgress,
  ) async {
    final fileName = _fileNameFromUrl(doc.remoteUrl, doc.id);
    final localPath = await _downloadService.downloadFile(
      doc.remoteUrl,
      fileName,
      onProgress: onProgress,
    );

    final updated = DownloadedDocument(
      id: doc.id,
      title: doc.title,
      remoteUrl: doc.remoteUrl,
      localPath: localPath,
      downloadedAt: DateTime.now(),
    );

    await save(updated);
    return updated;
  }

  Future<void> save(DownloadedDocument doc) async {
    try {
      await _box.put(doc.id, doc);
      await _metadataBox.put(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('DocumentRepository.save error: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      final doc = await getById(id);
      if (doc != null && doc.localPath != null) {
        final f = File(doc.localPath!);
        if (await f.exists()) await f.delete();
      }
      await _box.delete(id);
    } catch (e) {
      print('DocumentRepository.delete error: $e');
    }
  }

  Future<bool> exists(String id) async {
    try {
      return _box.containsKey(id);
    } catch (e) {
      print('DocumentRepository.exists error: $e');
      return false;
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      print('DocumentRepository.clear error: $e');
    }
  }

  String _fileNameFromUrl(String url, String id) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final rawName = segments.isNotEmpty ? segments.last : id;
      return '${DateTime.now().millisecondsSinceEpoch}_$rawName';
    } catch (_) {
      return '${DateTime.now().millisecondsSinceEpoch}_$id.pdf';
    }
  }
}
