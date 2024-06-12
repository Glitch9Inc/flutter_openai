import 'package:collection/collection.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

export 'embedding_data.dart';

/// {@template openai_embeddings_model}
/// This class is used to represent an OpenAI embeddings request.
/// {@endtemplate}
@immutable
final class Embedding {
  /// The data returned by the embeddings request.
  final List<EmbeddingData> data;

  /// The model used to generate the embeddings.
  final String model;

  /// The usage of the embeddings, if any.
  final Usage? usage;

  /// Weither the embeddings have at least one item in [data].
  bool get haveData => data.isNotEmpty;

  /// Weither the embeddings have a usage information.
  bool get haveUsage => usage != null;

  @override
  int get hashCode => data.hashCode ^ model.hashCode ^ usage.hashCode;

  /// {@macro openai_embeddings_model}
  const Embedding({
    required this.data,
    required this.model,
    required this.usage,
  });

  /// {@macro openai_embeddings_model}
  /// This method is used to convert a [Map<String, dynamic>] object to a [Embedding] object.
  factory Embedding.fromMap(Map<String, dynamic> map) {
    return Embedding(
      data: List<EmbeddingData>.from(
        map['data'].map<EmbeddingData>(
          (x) => EmbeddingData.fromMap(x as Map<String, dynamic>),
        ),
      ),
      model: map['model'] as String,
      usage: Usage.fromMap(
        map['usage'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  bool operator ==(covariant Embedding other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.data, data) && other.model == model && other.usage == usage;
  }

  @override
  String toString() => 'OpenAIEmbeddingsModel(data: $data, model: $model, usage: $usage)';
}
