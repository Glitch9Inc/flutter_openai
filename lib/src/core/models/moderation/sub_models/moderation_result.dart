import 'package:meta/meta.dart';

import 'moderation_catgeories.dart';
import 'moderation_catgeories_scores.dart';

export 'moderation_catgeories.dart';
export 'moderation_catgeories_scores.dart';

/// {@template openai_moderation_result_model}
///  This class is used to represent an OpenAI moderation job result.
/// {@endtemplate}
@immutable
final class ModerationResult {
  /// The categories of the moderation job.
  final ModerationResultCategories categories;

  /// The category scores of the moderation job.
  final ModerationResultScores categoryScores;

  /// The flagged status of the moderation job.
  final bool flagged;

  @override
  int get hashCode => categories.hashCode ^ categoryScores.hashCode ^ flagged.hashCode;

  /// {@macro openai_moderation_result_model}
  const ModerationResult({
    required this.categories,
    required this.categoryScores,
    required this.flagged,
  });

  /// This method is used to convert a [Map<String, dynamic>] object to a [ModerationResult] object.
  factory ModerationResult.fromMap(Map<String, dynamic> json) {
    return ModerationResult(
      categories: ModerationResultCategories.fromMap(
        json['categories'],
      ),
      categoryScores: ModerationResultScores.fromMap(
        json['category_scores'],
      ),
      flagged: json['flagged'],
    );
  }

  @override
  String toString() =>
      'OpenAIModerationResultModel(categories: $categories, categoryScores: $categoryScores, flagged: $flagged)';

  @override
  bool operator ==(covariant ModerationResult other) {
    if (identical(this, other)) return true;

    return other.categories == categories &&
        other.categoryScores == categoryScores &&
        other.flagged == flagged;
  }
}
