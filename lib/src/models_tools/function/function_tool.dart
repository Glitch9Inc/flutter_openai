import 'package:collection/collection.dart';

import '../../flutter_openai_internal.dart';

export 'function_property.dart';

/// {@template openai_function}
/// This class is used to represent an OpenAI function.
/// {@endtemplate}
class FunctionTool {
  /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain
  /// underscores and dashes, with a maximum length of 64.
  final String? name;

  /// The description of what the function does.
  final String? description;

  /// The parameters the functions accepts, described as a
  /// [JSON Schema](https://json-schema.org/understanding-json-schema) object.
  final Map<String, dynamic>? parametersSchema;

  /// The arguments of the function.
  final String? arguments;

  /// The delegate of the function.
  final FunctionDelegate? delegate;

  /// Weither the function have a description.
  bool get hasDescription => description != null;

  /// Weither the function have arguments or not.
  bool get hasArguments => arguments != null;

  @override
  int get hashCode =>
      name.hashCode ^ description.hashCode ^ parametersSchema.hashCode ^ arguments.hashCode;

  /// {@macro openai_function}
  FunctionTool({
    required this.name,
    this.parametersSchema,
    this.description,
    this.arguments,
    this.delegate,
  });

  factory FunctionTool.create({
    required String name,
    String? description,
    String? arguments,
  }) {
    return FunctionTool(
      name: name,
      description: description,
      arguments: arguments,
    );
  }

  factory FunctionTool.createWithDelegate({
    required String name,
    String? description,
    String? arguments,
    required FunctionDelegate delegate,
  }) {
    return FunctionTool(
      name: name,
      description: description,
      arguments: arguments,
      delegate: delegate,
    );
  }

  /// {@macro openai_function}
  /// This a factory constructor that allows you to create a new function with valid parameters schema.
  factory FunctionTool.withParameters({
    required String name,
    String? description,
    required Iterable<FunctionProperty> parameters,
  }) {
    return FunctionTool(
      name: name,
      description: description,
      parametersSchema: FunctionProperty.object(
        name: '',
        properties: parameters,
      ).typeMap(),
    );
  }

  /// This method is used to convert a [Map<String, dynamic>] object to a [FunctionTool] object.
  factory FunctionTool.fromMap(Map<String, dynamic> map) {
    return FunctionTool(
      name: MapSetter.set<String>(map, 'name'),
      description: MapSetter.set<String>(map, 'description'),
      parametersSchema: MapSetter.set<Map<String, dynamic>>(map, 'parameters'),
      arguments: MapSetter.set<String>(map, 'arguments'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (parametersSchema != null) 'parameters': parametersSchema,
      if (arguments != null) 'arguments': arguments,
    };
  }

  @override
  String toString() =>
      'Function(name: $name, description: $description, parametersSchema: $parametersSchema, arguments: $arguments)';

  @override
  bool operator ==(covariant FunctionTool other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.description == description &&
        mapEquals(other.parametersSchema, parametersSchema) &&
        other.arguments == arguments;
  }
}
