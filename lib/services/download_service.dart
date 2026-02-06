import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Download a file from [url] and save it under application documents with [fileName].
  /// Returns the local file path on success.
  Future<String> downloadFile(
    String url,
    String fileName, {
    void Function(int sent, int total)? onProgress,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      final file = File(savePath);

      // Create parent dir if needed
      await file.parent.create(recursive: true);

      final response = await _dio
          .download(
            url,
            savePath,
            onReceiveProgress: onProgress,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
            ),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return savePath;
      } else {
        // remove partial file
        if (await file.exists()) await file.delete();
        throw Exception('Download failed: HTTP ${response.statusCode}');
      }
    } on DioError catch (e) {
      // Clean partial file
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) await file.delete();
      } catch (_) {}
      rethrow;
    }
  }
}
