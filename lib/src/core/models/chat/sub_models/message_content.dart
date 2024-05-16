// ignore_for_file: public_member_api_docs, sort_constructors_first
/// {@template openai_chat_completion_choice_message_content_item_model}
/// This represents the content item of the [OpenAIChatCompletionChoiceMessageModel] model of the OpenAI API, which is used in the [OpenAIChat] methods.
/// {@endtemplate}
class MessageContent {
  /// The type of the content item.
  final String type;

  /// The text content of the item.
  final String? text;

  /// The image url object.
  final Map<String, dynamic>? imageUrl;

  final String? imageBase64;

  @override
  int get hashCode => type.hashCode ^ text.hashCode ^ imageUrl.hashCode;

  /// {@macro openai_chat_completion_choice_message_content_item_model}
  MessageContent._({
    required this.type,
    this.text,
    this.imageUrl,
    this.imageBase64,
  });

  /// This is used to convert a [Map<String, dynamic>] object to a [MessageContent] object.
  factory MessageContent.fromMap(
    Map<String, dynamic> asMap,
  ) {
    return MessageContent._(
      type: asMap['type'],
      text: asMap['text'],
      imageUrl: asMap['image_url'],
      imageBase64: asMap['imageBase64'],
    );
  }

  /// Represents a text content item factory, which is used to create a text [MessageContent].
  factory MessageContent.text(String text) {
    return MessageContent._(
      type: 'text',
      text: text,
    );
  }

  /// Represents a image content item factory, which is used to create a image [MessageContent].
  factory MessageContent.imageUrl(
    String imageUrl,
  ) {
    return MessageContent._(
      type: 'image_url',
      imageUrl: {'url': imageUrl},
    );
  }

  factory MessageContent.imageBase64(
    String imageBase64,
  ) {
    return MessageContent._(
      type: 'image_base64',
      imageBase64: imageBase64,
    );
  }

  /// This method used to convert the [MessageContent] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      if (text != null) "text": text,
      if (imageUrl != null) "image_url": imageUrl,
      if (imageBase64 != null) "image_url": {"url": "data:image/jpeg;base64,${imageBase64}"},
    };
  }

  @override
  bool operator ==(
    covariant MessageContent other,
  ) {
    if (identical(this, other)) return true;

    return other.type == type &&
        other.text == text &&
        other.imageUrl == imageUrl &&
        other.imageBase64 == imageBase64;
  }

  @override
  String toString() => switch (type) {
        'text' => 'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type, text: $text)',
        'image' =>
          'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type, imageUrl: $imageUrl)',
        'image_base64' =>
          'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type, imageBase64: $imageBase64)',
        _ => 'OpenAIChatCompletionChoiceMessageContentItemModel(type: $type)',
      };
}
