import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'image_data.dart';

export 'image_data.dart';

@immutable
final class ImageObject {
  /// The time the image was [created].
  final DateTime created;

  /// The data of the image.
  final List<ImageData> data;

  /// Weither the image have some [data].
  bool get haveData => data.isNotEmpty;

  @override
  int get hashCode => created.hashCode ^ data.hashCode;

  /// This class is used to represent an OpenAI image.
  const ImageObject({
    required this.created,
    required this.data,
  });

  /// This method is used to convert a [Map<String, dynamic>] object to a [ImageObject] object.
  factory ImageObject.fromMap(Map<String, dynamic> json) {
    return ImageObject(
      created: DateTime.fromMillisecondsSinceEpoch(json['created'] * 1000),
      data: (json['data'] as List).map((e) => ImageData.fromMap(e)).toList(),
    );
  }

  @override
  String toString() => 'OpenAIImageModel(created: $created, data: $data)';

  @override
  bool operator ==(covariant ImageObject other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.created == created && listEquals(other.data, data);
  }
}
