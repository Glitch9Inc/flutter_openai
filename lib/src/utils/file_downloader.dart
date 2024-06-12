import 'dart:io';

import 'package:flutter_openai/src/utils/openai_logger.dart';
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

        OpenAILogger.log('File downloaded and saved to $filePath');
        return file;
      } else {
        OpenAILogger.error('Failed to download file. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      OpenAILogger.error('Error downloading file: $e');
    }

    return null;
  }
}
