// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

/// {@template openai_tool_model}
///  This class is used to represent an OpenAI tool.
/// {@endtemplate}
@immutable
class FunctionToolCall {
  /// The type of the tool.
  final String type;

  /// The function of the tool.
  final FunctionTool function;

  @override
  int get hashCode => type.hashCode ^ function.hashCode;

  /// {@macro openai_tool_model}
  const FunctionToolCall({
    required this.type,
    required this.function,
  });

  /// This method is used to convert a [Map<String, dynamic>] object to a [FunctionToolCall] object.
  factory FunctionToolCall.fromMap(Map<String, dynamic> map) {
    return FunctionToolCall(
      type: map['type'],
      function: FunctionTool.fromMap(map['function']),
    );
  }

  /// This method is used to convert a [FunctionToolCall] object to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'function': function.toMap(),
    };
  }

  @override
  bool operator ==(covariant FunctionToolCall other) {
    if (identical(this, other)) return true;

    return other.type == type && other.function == function;
  }

  @override
  String toString() => 'OpenAIToolModel(type: $type, function: $function)';
}
