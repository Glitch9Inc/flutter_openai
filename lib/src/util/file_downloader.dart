import 'dart:io';

import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:http/http.dart' as http;

abstract class FileDownloader {
  static Future<File?> downloadFile(String imageUrl, String fileName) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        var documentDirectory = await Directory.systemTemp.createTemp('flutter_openai');
        var filePath = '${documentDirectory.path}/$fileName';

        // 파일로 저장
        var file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        OpenAI.logger.info('File downloaded and saved to $filePath');
        return file;
      } else {
        OpenAI.logger.severe('Failed to download file. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      OpenAI.logger.severe('Error downloading file: $e');
    }

    return null;
  }
}
