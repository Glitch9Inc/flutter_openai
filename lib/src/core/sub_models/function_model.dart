class FunctionModel {
  /// The name of the function.
  final String? name;
  final String? description;
  final String? parameters;

  /// The arguments of the function.
  final String? arguments;

  //! Not sure if the arguments will always be a Map<String, dynamic>, if you do confirm it from OpenAI docs please open an issue.

  /// Weither the function have a name or not.
  bool get hasName => name != null;

  /// Weither the function have arguments or not.
  bool get hasArguments => arguments != null;

  @override
  int get hashCode => name.hashCode ^ arguments.hashCode;

  /// {@macro openai_chat_completion_response_function_model}
  FunctionModel({
    this.name,
    this.arguments,
    this.description,
    this.parameters,
  });

  /// This method used to convert a [Map<String, dynamic>] object to a [FunctionModel] object.
  factory FunctionModel.fromMap(Map<String, dynamic> map) {
    return FunctionModel(
      name: map['name'],
      arguments: map['arguments'],
    );
  }

  /// This method used to convert the [FunctionModel] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "arguments": arguments,
    };
  }

  @override
  String toString() => 'FunctionModel(name: $name, arguments: $arguments)';

  @override
  bool operator ==(covariant FunctionModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.arguments == arguments;
  }
}
