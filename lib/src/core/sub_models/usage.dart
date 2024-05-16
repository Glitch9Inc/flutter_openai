import 'package:meta/meta.dart';

/// {@template openai_completion_model_usage}
/// This represents the usage of a completion response.
/// {@endtemplate}
@immutable
final class Usage {
  /// The number of tokens in the prompt.
  final int? promptTokens;

  /// The number of tokens in the completion.
  final int? completionTokens;

  /// The total number of tokens in the prompt and completion.
  final int? totalTokens;

  /// Whether the usage have a prompt tokens information.
  bool get havePromptTokens => promptTokens != null;

  /// Whether the usage have a completion tokens information.
  bool get haveCompletionTokens => completionTokens != null;

  /// Whether the usage have a total tokens information.
  bool get haveTotalTokens => totalTokens != null;

  @override
  int get hashCode => promptTokens.hashCode ^ completionTokens.hashCode ^ totalTokens.hashCode;

  /// {@macro openai_completion_model_usage}
  const Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  /// {@macro openai_completion_model_usage}
  /// This method is used to convert a [Map<String, dynamic>] object to a [Usage] object.
  factory Usage.fromMap(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }

  @override
  bool operator ==(covariant Usage other) {
    if (identical(this, other)) return true;

    return other.promptTokens == promptTokens &&
        other.completionTokens == completionTokens &&
        other.totalTokens == totalTokens;
  }

  @override
  String toString() =>
      'Usage(promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens)';
}
