// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../flutter_openai_internal.dart';

enum ToolType {
  codeInterpreter,
  fileSearch,
  function,
  jsonObject,
}

const toolTypeMap = {
  ToolType.codeInterpreter: "code_interpreter",
  ToolType.fileSearch: "file_search",
  ToolType.function: "function",
  ToolType.jsonObject: "json_object",
};

extension ToolTypeExtension on ToolType {
  String? get name => toolTypeMap[this];

  static ToolType parse(String enumName) {
    for (var key in toolTypeMap.keys) {
      if (toolTypeMap[key] == enumName) {
        return key;
      }
    }

    return ToolType.function;
  }
}

/// {@template openai_chat_completion_response_tool_call_model}
/// This represents the tool call of the [OpenAIChatCompletionChoiceMessageModel] model of the OpenAI API, which is used and get returned while using the [OpenAIChat] methods.
/// {@endtemplate}
class ToolCall {
  /// The id of the tool call.
  final String? id;

  /// The type of the tool call.
  final ToolType? type;

  /// The function of the tool call.
  final FunctionObject? function;

  /// Weither the tool call have an id.
  bool get haveId => id != null;

  /// Weither the tool call have a type.
  bool get haveType => type != null;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ function.hashCode;

  /// {@macro openai_chat_completion_response_tool_call_model}
  ToolCall({
    this.id,
    this.type,
    this.function,
  });

  /// This is used  to convert a [Map<String, dynamic>] object to a [ToolCall] object.
  factory ToolCall.fromMap(Map<String, dynamic> map) {
    return ToolCall(
      id: MapSetter.set<String>(map, 'id'),
      type: MapSetter.set<ToolType>(map, 'type', stringFactory: ToolTypeExtension.parse),
      function: MapSetter.set<FunctionObject>(map, 'function', factory: FunctionObject.fromMap),
    );
  }

  /// This method used to convert the [ToolCall] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (type != null) "type": type?.name,
      if (function != null) "function": function?.toMap(),
    };
  }

  @override
  String toString() {
    return "ToolCall(id: $id, type: $type)";
  }

  @override
  bool operator ==(covariant ToolCall other) {
    if (identical(this, other)) return true;

    return other.id == id && other.type == type && other.function == function;
  }
}

/// {@template openai_chat_completion_response_stream_tool_call_model}
/// This represents the stream tool call of the [OpenAIChatCompletionChoiceMessageModel] model of the OpenAI API, which is used and get returned while using the [OpenAIChat] methods.
/// {@endtemplate}
class StreamToolCall extends ToolCall {
  /// The index of the tool call.
//! please fill an issue if it happen that the index is not an int in some cases.
  final int index;

  @override
  int get hashCode => super.hashCode ^ index.hashCode;

  /// {@macro openai_chat_completion_response_stream_tool_call_model}
  StreamToolCall({
    required super.id,
    required super.type,
    required super.function,
    required this.index,
  });

  /// This is used  to convert a [Map<String, dynamic>] object to a [StreamToolCall] object.
  factory StreamToolCall.fromMap(Map<String, dynamic> map) {
    return StreamToolCall(
      id: map['id'],
      type: map['type'],
      function: FunctionObject.fromMap(map['function']),
      index: map['index'],
    );
  }

  /// This method used to convert the [StreamToolCall] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (type != null) "type": type?.name,
      if (function != null) "function": function?.toMap(),
      "index": index,
    };
  }

  @override
  bool operator ==(covariant StreamToolCall other) {
    if (identical(this, other)) return true;

    return other.index == index;
  }

  @override
  String toString() => 'OpenAIStreamResponseToolCall(index: $index})';
}
