// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_openai/src/core/utils/map_setter.dart';

/// {@template openai_chat_completion_choice_message_content_item_model}
/// This represents the content item of the [OpenAIChatCompletionChoiceMessageModel] model of the OpenAI API, which is used in the [OpenAIChat] methods.
/// {@endtemplate}
class MessageContent {
  /// The type of the content item.
  final String type;

  /// The text content of the item.
  final MessageText? text;

  /// The image url object.
  final Map<String, String>? imageUrl;

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
    Map<String, dynamic> map,
  ) {
    return MessageContent._(
      type: map['type'],
      text: MapSetter.set<MessageText>(
        map,
        'text',
        factory: MessageText.fromMap,
      ),
      imageUrl: MapSetter.set<Map<String, String>>(
        map,
        'image_url',
      ),
      imageBase64: MapSetter.set<String>(map, 'imageBase64'),
    );
  }

  /// Represents a text content item factory, which is used to create a text [MessageContent].
  factory MessageContent.text(String text) {
    return MessageContent._(
      type: 'text',
      text: MessageText.fromString(text),
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
        'text' => 'MessageContent(type: $type, text: $text)',
        'image' => 'MessageContent(type: $type, imageUrl: $imageUrl)',
        'image_base64' => 'MessageContent(type: $type, imageBase64: $imageBase64)',
        _ => 'MessageContent(type: $type)',
      };
}

class MessageText {
  final String value;
  final List<Annotation> annotations;
  final bool isString;
  const MessageText({required this.value, required this.annotations, this.isString = false});
  factory MessageText.fromMap(map) {
    if (map is String) {
      return MessageText.fromString(map);
    }
    if (map is Map<String, dynamic>) {
      return MessageText(
        value: map['value'],
        annotations: MapSetter.setList(
          map,
          'annotations',
          factory: (annotation) => Annotation.fromMap(annotation),
        )!,
      );
    }
    throw Exception('Invalid message text type');
  }
  factory MessageText.fromString(String text) {
    return MessageText(
      value: text,
      annotations: [],
      isString: true,
    );
  }
}

abstract class Annotation {
  final String type;
  final String text;
  final int startIndex;
  final int endIndex;
  const Annotation({
    required this.type,
    required this.text,
    required this.startIndex,
    required this.endIndex,
  });
  factory Annotation.fromMap(Map<String, dynamic> map) {
    String type = map['type'];
    if (type == 'file_citation') {
      return FileCitationAnnotation.fromMap(map);
    } else if (type == 'file_path') {
      return FilePathAnnotation.fromMap(map);
    }
    throw Exception('Invalid annotation type');
  }
}

class FilePathAnnotation extends Annotation {
  final FilePath filePath;
  FilePathAnnotation({
    required this.filePath,
    required String type,
    required String text,
    required int startIndex,
    required int endIndex,
  }) : super(type: type, text: text, startIndex: startIndex, endIndex: endIndex);
  factory FilePathAnnotation.fromMap(Map<String, dynamic> map) {
    return FilePathAnnotation(
      filePath: FilePath.fromMap(map['file_path']),
      type: map['type'],
      text: map['text'],
      startIndex: map['start_index'],
      endIndex: map['end_index'],
    );
  }
}

class FileCitationAnnotation extends Annotation {
  final FileCitation fileCitation;
  const FileCitationAnnotation({
    required this.fileCitation,
    required String type,
    required String text,
    required int startIndex,
    required int endIndex,
  }) : super(type: type, text: text, startIndex: startIndex, endIndex: endIndex);
  factory FileCitationAnnotation.fromMap(Map<String, dynamic> map) {
    return FileCitationAnnotation(
      type: map['type'],
      text: map['text'],
      fileCitation: FileCitation.fromMap(map['file_citation']),
      startIndex: map['start_index'],
      endIndex: map['end_index'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'text': text,
      'file_citation': fileCitation.toMap(),
      'start_index': startIndex,
      'end_index': endIndex,
    };
  }
}

class FileCitation {
  final String fileId;
  final String quote;
  const FileCitation({required this.fileId, required this.quote});
  factory FileCitation.fromMap(Map<String, dynamic> map) {
    return FileCitation(
      fileId: map['file_id'],
      quote: map['quote'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'file_id': fileId,
      'quote': quote,
    };
  }
}

class FilePath {
  final String fileId;
  const FilePath({required this.fileId});
  factory FilePath.fromMap(Map<String, dynamic> map) {
    return FilePath(
      fileId: map['file_id'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'file_id': fileId,
    };
  }
}
