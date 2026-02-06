import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String localPath;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.localPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(localPath);
    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Fichier non trouvé: $localPath')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.file(file),
    );
  }
}
