import 'dart:typed_data';

import 'package:public_file_saver/public_file_saver.dart';

class FileDownloadService {
  static Future<String> savePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final result = await PublicFileSaver().saveBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/pdf',
      subDir: 'GoCare',
    );

    if (result == null) {
      throw Exception('Unable to save PDF');
    }

    return 'Downloads/GoCare/$fileName';
  }

  static Future<String> saveImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final result = await PublicFileSaver().saveBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'image/png',
      subDir: 'GoCare',
    );

    if (result == null) {
      throw Exception('Unable to save image');
    }

    return 'Downloads/GoCare/$fileName';
  }
}