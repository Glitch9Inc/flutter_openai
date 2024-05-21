import 'package:collection/collection.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

export '../usage/usage.dart';
export 'stream/chat_completion_chunk.dart';
export 'sub_models/chat_choices.dart';

/// {@template openai_chat_completion_model}
/// This class represents the chat completion response model of the OpenAI API, which is used and get returned while using the [OpenAIChat] methods.
/// {@endtemplate}
@immutable
final class ChatCompletion {
  /// The [id]entifier of the chat completion.
  final String id;

  /// The date and time when the chat completion was [created].
  final DateTime created;

  /// The [choices] of the chat completion.
  final List<ChatChoice> choices;

  /// The [usage] of the chat completion.
  final Usage usage;

  /// This fingerprint represents the backend configuration that the model runs with.
  final String? systemFingerprint;

  /// Weither the chat completion have at least one choice in [choices].
  bool get haveChoices => choices.isNotEmpty;

  /// Weither the chat completion have system fingerprint.
  bool get haveSystemFingerprint => systemFingerprint != null;

  @override
  int get hashCode {
    return id.hashCode ^
        created.hashCode ^
        choices.hashCode ^
        usage.hashCode ^
        systemFingerprint.hashCode;
  }

  /// {@macro openai_chat_completion_model}
  const ChatCompletion({
    required this.id,
    required this.created,
    required this.choices,
    required this.usage,
    required this.systemFingerprint,
  });

  /// This is used  to convert a [Map<String, dynamic>] object to a [ChatCompletion] object.
  factory ChatCompletion.fromMap(Map<String, dynamic> json) {
    return ChatCompletion(
      id: json['id'],
      created: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
      choices: (json['choices'] as List).map((choice) => ChatChoice.fromMap(choice)).toList(),
      usage: Usage.fromMap(json['usage']),
      systemFingerprint: json['system_fingerprint'],
    );
  }

  /// This is used to convert a [ChatCompletion] object to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "created": created.millisecondsSinceEpoch,
      "choices": choices.map((e) => e.toMap()).toList(),
      "usage": usage.toMap(),
      "system_fingerprint": systemFingerprint,
    };
  }

  @override
  String toString() {
    return 'ChatCompletion(id: $id, created: $created, choices: $choices, usage: $usage, systemFingerprint: $systemFingerprint)';
  }

  @override
  bool operator ==(Object other) {
    const ListEquality listEquals = ListEquality();
    if (identical(this, other)) return true;

    return other is ChatCompletion &&
        other.id == id &&
        other.created == created &&
        listEquals.equals(other.choices, choices) &&
        other.usage == usage &&
        other.systemFingerprint == systemFingerprint;
  }
}
