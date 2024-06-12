import 'package:collection/collection.dart';

import 'chunk_choice.dart';

export 'chunk_choice.dart';

/// {@template openai_stream_chat_completion}
/// The [ChatCompletionChunk] class represents the chat completion response model of the OpenAI API, which is used and get returned while using the chat methods that leverages [Stream] functionality.
/// {@endtemplate}
final class ChatCompletionChunk {
  /// The [id] of the chat completion.
  final String id;

  /// The date and time when the chat completion is [created].
  final DateTime created;

  /// The [choices] of the chat completion.
  final List<ChunkChoice> choices;

  /// This fingerprint represents the backend configuration that the model runs with.
  final String? systemFingerprint;

  /// Wether the chat completion have at least one choice in [choices].
  bool get haveChoices => choices.isNotEmpty;

  /// Wether the chat completion have a [systemFingerprint] or not.
  bool get haveSystemFingerprint => systemFingerprint != null;

  @override
  int get hashCode {
    return id.hashCode ^ created.hashCode ^ choices.hashCode ^ systemFingerprint.hashCode;
  }

  /// {@macro openai_stream_chat_completion}
  const ChatCompletionChunk({
    required this.id,
    required this.created,
    required this.choices,
    required this.systemFingerprint,
  });

  /// {@macro openai_stream_chat_completion}
  /// This is used  to convert a [Map<String, dynamic>] object to a [ChatCompletionChunk] object.
  factory ChatCompletionChunk.fromMap(Map<String, dynamic> json) {
    return ChatCompletionChunk(
      id: json['id'],
      created: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
      choices: (json['choices'] as List)
          .map(
            (choice) => ChunkChoice.fromMap(choice),
          )
          .toList(),
      systemFingerprint: json['system_fingerprint'],
    );
  }

//! This don't need toMap()?

  @override
  String toString() {
    return 'OpenAIStreamChatCompletionModel(id: $id, created: $created, choices: $choices, systemFingerprint: $systemFingerprint)';
  }

  @override
  bool operator ==(Object other) {
    const ListEquality listEquals = ListEquality();
    if (identical(this, other)) return true;

    return other is ChatCompletionChunk &&
        other.id == id &&
        other.created == created &&
        listEquals.equals(other.choices, choices) &&
        other.systemFingerprint == systemFingerprint;
  }
}
