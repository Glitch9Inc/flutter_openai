import 'package:meta/meta.dart';

/// {@template openai_fine_tune_event_stream_model}
/// Creates a new instance of [FineTuningEventChunk].
/// {@endtemplate}
@immutable
final class FineTuningEventChunk {
  /// The [level] of the event.
  final String level;

  /// The [message] of the event.
  final String message;

  /// The time the event was [created].
  final DateTime createdAt;

  @override
  int get hashCode => level.hashCode ^ message.hashCode ^ createdAt.hashCode;

  /// {@macro openai_fine_tune_event_stream_model}
  const FineTuningEventChunk({
    required this.level,
    required this.message,
    required this.createdAt,
  });

  /// {@macro openai_fine_tune_event_stream_model}
  /// Creates a new instance of [FineTuningEventChunk] from a [Map].
  factory FineTuningEventChunk.fromMap(Map<String, dynamic> json) {
    return FineTuningEventChunk(
      level: json['level'] as String,
      message: json['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000),
    );
  }

  @override
  String toString() =>
      'OpenAIFineTuneEventStreamModel(level: $level, message: $message, createdAt: $createdAt)';

  @override
  bool operator ==(covariant FineTuningEventChunk other) {
    if (identical(this, other)) return true;

    return other.level == level && other.message == message && other.createdAt == createdAt;
  }
}
