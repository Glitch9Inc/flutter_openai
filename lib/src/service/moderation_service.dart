import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

/// {@template openai_moderation}
/// The class that handles all the requests related to the moderation in the OpenAI API.
/// {@endtemplate}
@immutable
@protected
interface class ModerationService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.moderation;

  /// Creates a moderation request.
  ///
  ///
  /// [input] is the input text to classify.
  ///
  ///
  /// [model] is the used model for this operation, two content moderation models are available: "text-moderation-stable" and "text-moderation-latest".
  /// The default is text-moderation-latest which will be automatically upgraded over time. This ensures you are always using our most accurate model. If you use text-moderation-stable, we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be slightly lower than for text-moderation-latest.
  ///
  ///
  /// Example:
  /// ```dart
  /// final moderation = await openai.moderation.create(
  ///  input: "I will kill your mates before I will cut your head off",
  /// );
  ///
  /// print(moderation.results); // ...
  /// print(moderation.results.first.categories.hate); // ...
  /// ```
  Future<ModerationObject> create({
    required String input,
    String? model,
  }) async {
    return await OpenAIClient.post<ModerationObject>(
      create: (Map<String, dynamic> response) {
        return ModerationObject.fromMap(response);
      },
      body: {
        "input": input,
        if (model != null) "model": model,
      },
      to: endpoint,
    );
  }
}
