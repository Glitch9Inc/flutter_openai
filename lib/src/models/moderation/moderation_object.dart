// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'sub_models/moderation_result.dart';

export 'sub_models/moderation_result.dart';

/// {@template openai_moderation_model}
///  This class is used to represent an OpenAI moderation job.
/// {@endtemplate}
@immutable
final class ModerationObject {
  /// The [id]entifier of the moderation job.
  final String id;

  /// The [model] used for moderation.
  final String model;

  /// The [results] of the moderation job.
  final List<ModerationResult> results;

  /// Weither the moderation job have at least one result in [results].
  bool get haveResults => results.isNotEmpty;

  @override
  int get hashCode => id.hashCode ^ model.hashCode ^ results.hashCode;

  /// {@macro openai_moderation_model}
  const ModerationObject({
    required this.id,
    required this.model,
    required this.results,
  });

  /// This method is used to convert a [Map<String, dynamic>] object to a [ModerationObject] object.
  factory ModerationObject.fromMap(Map<String, dynamic> json) {
    return ModerationObject(
      id: json['id'],
      model: json['model'],
      results: List<ModerationResult>.from(
        json['results'].map(
          (x) => ModerationResult.fromMap(x),
        ),
      ),
    );
  }

  @override
  String toString() => 'OpenAIModerationModel(id: $id, model: $model, results: $results)';

  @override
  bool operator ==(covariant ModerationObject other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id && other.model == model && listEquals(other.results, results);
  }
}
