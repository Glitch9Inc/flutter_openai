import 'dart:io';

import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/models/image/image_object.dart';
import 'package:flutter_openai/src/request/interfaces/image_interface.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../core/constants/strings.dart';
import '../core/enum.dart';
import '../core/utils/openai_logger.dart';

/// {@template openai_images}
/// The class that handles all the requests related to the images in the OpenAI API.
/// {@endtemplate}
@immutable
@protected
interface class ImageRequest implements ImageInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.images;

  /// {@macro openai_images}
  ImageRequest() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// This function creates an image based on a given prompt.
  ///
  /// [model] is the model to use for generating the image.
  ///
  ///
  /// [prompt] is a text description of the desired image(s). The maximum length is 1000 characters.
  ///
  ///
  /// [n] is the number of images to generate. Must be between 1 and 10.
  ///
  ///
  /// [size] is the size of the generated images, each OpenAI model has a different set of available/allowed sizes:
  ///
  /// `dall-e-2` model only:
  /// - `OpenAIImageSize.size256`
  /// - `OpenAIImageSize.size512`
  /// `dall-e-2` or `dall-e-3` model:
  /// - `OpenAIImageSize.size1024`
  /// `dall-e-3` model only:
  /// - `OpenAIImageSize.size1792Horizontal`
  /// - `OpenAIImageSize.size1792Vertical`
  ///
  /// [responseFormat] is the format in which the generated images are returned. Must be one of :
  /// - `OpenAIImageResponseFormat.url`
  /// - `OpenAIImageResponseFormat.b64Json`
  ///
  /// [style] is the style of the generated images and is only available for the `dall-e-3` model. Must be one of:
  /// - `OpenAIImageStyle.vivid`
  /// - `OpenAIImageStyle.natural`
  ///
  /// [quality] is the quality of the generated images and is only available for the `dall-e-3` model. Must be one of:
  /// - `OpenAIImageQuality.hd`
  ///
  /// [user] is the user ID to associate with the request. This is used to prevent abuse of the API.
  ///
  ///
  /// Example:
  ///```dart
  /// OpenAIImageModel image = await OpenAI.instance.image.create(
  ///  prompt: 'create an image about the sea',
  ///  n: 1,
  ///  size: OpenAIImageSize.size1024,
  ///  responseFormat: OpenAIImageResponseFormat.url,
  /// );
  ///```
  @override
  Future<ImageObject> create({
    String? model,
    required String prompt,
    int? n,
    ImageSize? size,
    ImageStyle? style,
    ImageQuality? quality,
    ImageResponseFormat? responseFormat,
    String? user,
    http.Client? client,
  }) async {
    final String generations = "/generations";

    return await OpenAIClient.post(
      to: BaseApiUrlBuilder.build(endpoint + generations),
      onSuccess: (json) => ImageObject.fromMap(json),
      body: {
        if (model != null) "model": model,
        "prompt": prompt,
        if (n != null) "n": n,
        if (size != null) "size": size.value,
        if (style != null) "style": style.value,
        if (quality != null) "quality": quality.value,
        if (responseFormat != null) "response_format": responseFormat.value,
        if (user != null) "user": user,
      },
      client: client,
    );
  }

  /// Creates an edited or extended image given an original image and a prompt.
  ///
  /// [model] is the model to use for generating the image.
  ///
  ///
  /// [image] to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
  ///
  ///
  /// [mask] defines an additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
  ///
  ///
  /// [prompt] A text description of the desired image(s). The maximum length is 1000 characters.
  ///
  /// [n] is the number of images to generate. Must be between 1 and 10.
  ///
  ///
  /// [size] is the size of the generated images. Must be one of :
  /// - `OpenAIImageSize.size256`
  /// - `OpenAIImageSize.size512`
  /// - `OpenAIImageSize.size1024`
  ///
  ///
  /// [responseFormat] is the format in which the generated images are returned. Must be one of :
  /// - `OpenAIImageResponseFormat.url`
  /// - `OpenAIImageResponseFormat.b64Json`
  ///
  ///
  ///
  /// [user] is the user ID to associate with the request. This is used to prevent abuse of the API.
  ///
  ///
  /// Example:
  ///```dart
  /// OpenAIImageModel imageEdit = await OpenAI.instance.image.edit(
  ///  file: File(/* IMAGE PATH HERE */),
  ///  mask: File(/* MASK PATH HERE */),
  ///  prompt: "mask the image with a dinosaur in the image",
  ///  n: 1,
  ///  size: OpenAIImageSize.size1024,
  ///  responseFormat: OpenAIImageResponseFormat.url,
  /// );
  ///```
  @override
  Future<ImageObject> edit({
    String? model,
    required File image,
    File? mask,
    required String prompt,
    int? n,
    ImageSize? size,
    ImageResponseFormat? responseFormat,
    String? user,
  }) async {
    final String edit = "/edits";

    return await OpenAIClient.imageEditForm<ImageObject>(
      image: image,
      mask: mask,
      body: {
        if (model != null) "model": model,
        "prompt": prompt,
        if (n != null) "n": n.toString(),
        if (size != null) "size": size.value,
        if (responseFormat != null) "response_format": responseFormat.value,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return ImageObject.fromMap(response);
      },
      to: BaseApiUrlBuilder.build(endpoint + edit),
    );
  }

  /// Creates a variation of a given image.
  ///
  ///
  /// [model] is the model to use for generating the image.
  ///
  ///
  /// [image] to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
  ///
  ///
  /// [n] is the number of images to generate. Must be between 1 and 10.
  ///
  ///
  /// [size] is the size of the generated images. Must be one of :
  /// - `OpenAIImageSize.size256`
  /// - `OpenAIImageSize.size512`
  /// - `OpenAIImageSize.size1024`
  ///
  ///
  /// [responseFormat] is the format in which the generated images are returned. Must be one of :
  /// - `OpenAIImageResponseFormat.url`
  /// - `OpenAIImageResponseFormat.b64Json`
  ///
  ///
  /// [user] is the user ID to associate with the request. This is used to prevent abuse of the API.
  ///
  ///
  /// Example:
  /// ```dart
  /// OpenAIImageModel imageVariation = await OpenAI.instance.image.variation(
  /// image: File(/* IMAGE PATH HERE */),
  /// n: 1,
  /// size: OpenAIImageSize.size1024,
  /// responseFormat: OpenAIImageResponseFormat.url,
  /// );
  /// ```
  @override
  Future<ImageObject> variation({
    String? model,
    required File image,
    int? n,
    ImageSize? size,
    ImageResponseFormat? responseFormat,
    String? user,
  }) async {
    final String variations = "/variations";

    return await OpenAIClient.imageVariationForm<ImageObject>(
      image: image,
      body: {
        if (model != null) "model": model,
        if (n != null) "n": n.toString(),
        if (size != null) "size": size.value,
        if (responseFormat != null) "response_format": responseFormat.value,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return ImageObject.fromMap(response);
      },
      to: BaseApiUrlBuilder.build(endpoint + variations),
    );
  }
}
