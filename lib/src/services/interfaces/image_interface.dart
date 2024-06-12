import 'dart:io';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/services/interfaces/shared_interfaces.dart';

abstract class ImageInterface implements EndpointInterface {
  Future<ImageObject> create({
    required String prompt,
    int? n,
    ImageSize? size,
    ImageResponseFormat? responseFormat,
    String? user,
  });

  Future<ImageObject> edit({
    required File image,
    File? mask,
    required String prompt,
    int? n,
    ImageSize? size,
    ImageResponseFormat? responseFormat,
    String? user,
  });

  Future<ImageObject> variation({
    required File image,
    int? n,
    ImageSize? size,
    ImageResponseFormat? responseFormat,
    String? user,
  });
}

extension SizeToStingExtension on ImageSize {
  String get value {
    switch (this) {
      case ImageSize.size256:
        return "256x256";
      case ImageSize.size512:
        return "512x512";
      case ImageSize.size1024:
        return "1024x1024";
      case ImageSize.size1792Horizontal:
        return "1792x1024";
      case ImageSize.size1792Vertical:
        return "1024x1792";
    }
  }
}

extension StyleToStingExtension on ImageStyle {
  String get value {
    return name;

    // ! pretty sure this will be needed in the future in case of adding more styles that can't be got from the `name` field.
    // switch (this) {
    //   case OpenAIImageStyle.vivid:
    //     return "vivid";
    //   case OpenAIImageStyle.natural:
    //     return "natural";
    // }
  }
}

extension QualityToStingExtension on ImageQuality {
  String get value {
    return name;

    // ! pretty sure this will be needed in the future in case of adding more qualities that can't be got from the `name` field.
    // switch (this) {
    //   case OpenAIImageQuality.hd:
    //     return "hd";
    // }
  }
}

extension ResponseFormatToStingExtension on ImageResponseFormat {
  String get value {
    switch (this) {
      case ImageResponseFormat.url:
        return "url";
      case ImageResponseFormat.b64Json:
        return "b64_json";
    }
  }
}
