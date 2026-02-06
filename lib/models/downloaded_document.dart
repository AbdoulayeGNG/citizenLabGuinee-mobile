import 'package:hive/hive.dart';

class DownloadedDocument {
  final String id;
  final String title;
  final String remoteUrl;
  final String? localPath;
  final DateTime downloadedAt;

  DownloadedDocument({
    required this.id,
    required this.title,
    required this.remoteUrl,
    this.localPath,
    required this.downloadedAt,
  });

  factory DownloadedDocument.fromJson(Map<String, dynamic> json) {
    return DownloadedDocument(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String? ?? '',
      localPath: json['localPath'] as String?,
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.parse(json['downloadedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'remoteUrl': remoteUrl,
      'localPath': localPath,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }
}

class DownloadedDocumentAdapter extends TypeAdapter<DownloadedDocument> {
  @override
  final int typeId = 50; // choose an id unlikely to collide

  @override
  DownloadedDocument read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read() as Map);
    return DownloadedDocument.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, DownloadedDocument obj) {
    writer.write(obj.toJson());
  }
}
