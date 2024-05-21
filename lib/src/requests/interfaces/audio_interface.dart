import 'dart:io';

import 'package:flutter_openai/src/requests/interfaces/shared_interfaces.dart';

import '../../../flutter_openai.dart';

abstract class AudioInterface implements EndpointInterface {
  Future<File> createSpeech({
    required String model,
    required String input,
    required String voice,
    SpeechResponseFormat? responseFormat,
    double? speed,
    String outputFileName = "output",
    Directory? outputDirectory,
  });

  Future<AudioObject> createTranscription({
    required File file,
    required String model,
    String? prompt,
    AudioResponseFormat? responseFormat,
    double? temperature,
    String? language,
    List<AudioTimestampGranularity>? timestamp_granularities,
  });

  Future<AudioObject> createTranslation({
    required File file,
    required String model,
    String? prompt,
    AudioResponseFormat? responseFormat,
    double? temperature,
  });
}
