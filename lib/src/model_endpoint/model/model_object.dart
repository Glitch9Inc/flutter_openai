import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'model_permission.dart';

/// {@template openai_model_model}
///  This class is used to represent an OpenAI model.
/// {@endtemplate}
@immutable
final class ModelObject {
  /// The [id]entifier of the model.
  final String id;

  /// The name of the organization that owns the model.
  final String ownedBy;

  /// The [permission]s of the model.
  final List<ModelPermission>? permission;

  /// Whether the model have at least one permission in [permission].
  bool get havePermission => permission != null;

  @override
  int get hashCode => id.hashCode ^ ownedBy.hashCode ^ permission.hashCode;

  /// {@macro openai_model_model}
  const ModelObject({
    required this.id,
    required this.ownedBy,
    required this.permission,
  });

  /// This method is used to convert a [Map<String, dynamic>] object to a [ModelObject] object.
  factory ModelObject.fromMap(Map<String, dynamic> json) {
    // Perform a null check, and if 'permission' is null, use an empty list or null.
    final permissionJson = json['permission'] as List?;
    final permissions = permissionJson != null
        ? permissionJson.map((e) => ModelPermission.fromMap(e as Map<String, dynamic>)).toList()
        : <ModelPermission>[];

    return ModelObject(
      id: json['id'],
      ownedBy: json['owned_by'],
      permission: permissions,
    );
  }

  @override
  String toString() => 'OpenAIModelModel(id: $id, ownedBy: $ownedBy, permission: $permission)';

  @override
  bool operator ==(covariant ModelObject other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id && other.ownedBy == ownedBy && listEquals(other.permission, permission);
  }
}
