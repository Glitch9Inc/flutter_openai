import 'dart:io';
import 'package:flutter_openai/flutter_openai.dart';

class TranscriptionRequest {
  final File file;
  final String model = "whisper-1";
  final String? prompt;
  final AudioResponseFormat? responseFormat;
  final double? temperature;
  final String? language;
  final List<AudioTimestampGranularity>? timestampGranularities;

  TranscriptionRequest({
    required this.file,
    this.prompt,
    this.responseFormat,
    this.temperature,
    this.language,
    this.timestampGranularities,
  });
}
