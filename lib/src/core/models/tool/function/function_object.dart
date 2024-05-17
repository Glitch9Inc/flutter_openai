import 'dart:convert';

import 'package:collection/collection.dart';

import '../../../../../flutter_openai.dart';

export 'function_property.dart';

/// {@template openai_function}
/// This class is used to represent an OpenAI function.
/// {@endtemplate}
class FunctionObject extends ToolBase {
  /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain
  /// underscores and dashes, with a maximum length of 64.
  final String name;

  /// The description of what the function does.
  final String? description;

  /// The parameters the functions accepts, described as a
  /// [JSON Schema](https://json-schema.org/understanding-json-schema) object.
  final Map<String, dynamic>? parametersSchema;

  /// The arguments of the function.
  final String? arguments;

  /// Weither the function have a description.
  bool get hasDescription => description != null;

  /// Weither the function have arguments or not.
  bool get hasArguments => arguments != null;

  @override
  int get hashCode =>
      name.hashCode ^ description.hashCode ^ parametersSchema.hashCode ^ arguments.hashCode;

  /// {@macro openai_function}
  FunctionObject({
    required this.name,
    this.parametersSchema,
    this.description,
    this.arguments,
  });

  /// {@macro openai_function}
  /// This a factory constructor that allows you to create a new function with valid parameters schema.
  factory FunctionObject.withParameters({
    required String name,
    String? description,
    required Iterable<FunctionProperty> parameters,
  }) {
    return FunctionObject(
      name: name,
      description: description,
      parametersSchema: FunctionProperty.object(
        name: '',
        properties: parameters,
      ).typeMap(),
    );
  }

  /// This method is used to convert a [Map<String, dynamic>] object to a [FunctionObject] object.
  factory FunctionObject.fromMap(Map<String, dynamic> map) {
    return FunctionObject(
      name: map['name'],
      description: map['description'],
      parametersSchema: map.containsKey('parameters')
          ? jsonDecode(map['parameters']) as Map<String, dynamic>
          : null,
      arguments: map['arguments'],
    );
  }

  /// This method is used to convert a [FunctionObject] object to a [Map<String, dynamic>] object.
  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (parametersSchema != null) 'parameters': jsonEncode(parametersSchema),
      if (arguments != null) 'arguments': arguments,
    };
  }

  @override
  String toString() =>
      'OpenAIFunction(name: $name, description: $description, parametersSchema: $parametersSchema, arguments: $arguments)';

  @override
  bool operator ==(covariant FunctionObject other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.description == description &&
        mapEquals(other.parametersSchema, parametersSchema) &&
        other.arguments == arguments;
  }
}
