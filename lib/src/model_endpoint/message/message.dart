// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_openai/src/model_common/incomplete_details.dart';
import 'package:flutter_openai/src/util/map_setter.dart';

import '../../model_common/enums.dart';
import '../../model_tool/tool_call.dart';
import '../chat/sub_models/message_content.dart';

export '../../model_tool/tool_call.dart';
export '../chat/sub_models/message_content.dart';

/// {@template openai_chat_completion_choice_message_model}
/// This represents the message of the [OpenAIChatCompletionChoiceModel] model of the OpenAI API, which is used and get returned while using the [OpenAIChat] methods.
/// {@endtemplate}
final class Message {
  /// The identifier, which can be referenced in API endpoints.
  final String? id;

  final String? object;

  /// The Unix timestamp (in seconds) for when the message was created.
  final DateTime? createdAt;

  /// The thread ID that this message belongs to.
  final String? threadId;

  /// The Unix timestamp (in seconds) for when the message was completed.
  final DateTime? completedAt;

  /// The Unix timestamp (in seconds) for when the message was marked as incomplete.
  final DateTime? incompleteAt;

  /// If applicable, the ID of the [assistant] that authored this message.
  final String? assistantId;

  /// The ID of the [run] associated with the creation of this message.
  /// Value is null when messages are created manually using the create message or create thread endpoints.
  final String? runId;

  /// Set of 16 key-value pairs that can be attached to an object.
  /// This can be useful for storing additional information about the object in a structured format.
  /// Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  final Map<String, String>? metadata;

  /// The status of the message, which can be either in_progress, incomplete, or completed.
  final MessageStatus? status;

  /// On an incomplete message, details about why the message is incomplete.
  final IncompleteDetails? incompleteDetails;

  /// The [role] of the message.
  final ChatRole role;

  /// The [content] of the message.
  final List<MessageContent>? content;

  /// The function that the model is requesting to call.
  final List<ToolCall>? toolCalls;

  final ToolCall? toolChoice;

  /// The message participent name.
  final String? name;

  /// Weither the message have tool calls.
  bool get haveToolCalls => toolCalls != null;

  /// Weither the message have content.
  bool get haveContent => content != null && content!.isNotEmpty;

  @override
  int get hashCode {
    return role.hashCode ^ content.hashCode ^ toolCalls.hashCode;
  }

  /// {@macro openai_chat_completion_choice_message_model}
  const Message({
    this.id,
    this.object,
    this.createdAt,
    this.threadId,
    required this.role,
    required this.content,
    this.toolCalls,
    this.toolChoice,
    this.name,
    this.metadata,
    this.status,
    this.incompleteDetails,
    this.assistantId,
    this.runId,
    this.completedAt,
    this.incompleteAt,
  });

  factory Message.fromText({
    String? id,
    String? object,
    DateTime? createdAt,
    String? threadId,
    required String text,
    required ChatRole role,
    List<ToolCall>? toolCalls,
    ToolCall? toolChoice,
    String? name,
    Map<String, String>? metadata,
    MessageStatus? status,
    IncompleteDetails? incompleteDetails,
    String? assistantId,
    String? runId,
    DateTime? completedAt,
    DateTime? incompleteAt,
  }) {
    return Message(
      id: id,
      object: object,
      createdAt: createdAt,
      threadId: threadId,
      role: role,
      content: [MessageContent.text(text)],
      toolCalls: toolCalls,
      name: name,
      metadata: metadata,
      status: status,
      incompleteDetails: incompleteDetails,
      assistantId: assistantId,
      runId: runId,
      completedAt: completedAt,
      incompleteAt: incompleteAt,
    );
  }

  /// This is used  to convert a [Map<String, dynamic>] object to a [Message] object.
  factory Message.fromMap(
    Map<String, dynamic> map,
  ) {
    return Message(
      id: MapSetter.set<String>(map, 'id'),
      object: MapSetter.set<String>(map, 'object'),
      createdAt: MapSetter.set<DateTime>(map, 'created_at'),
      threadId: MapSetter.set<String>(map, 'thread_id'),
      name: MapSetter.set<String>(map, 'name'),
      runId: MapSetter.set<String>(map, 'run_id'),
      assistantId: MapSetter.set<String>(map, 'assistant_id'),
      status: MapSetter.setEnum<MessageStatus>(
        map,
        'status',
        enumValues: MessageStatus.values,
        defaultValue: MessageStatus.none,
      ),
      incompleteDetails: MapSetter.set<IncompleteDetails>(
        map,
        'incomplete_details',
        factory: IncompleteDetails.fromMap,
      ),
      role: MapSetter.setEnum<ChatRole>(
        map,
        'role',
        enumValues: ChatRole.values,
        defaultValue: ChatRole.none,
      ),
      // content: MapSetter.setStringOr<MessageContent>(
      //   map,
      //   'content',
      //   stringFactory: MessageContent.text,
      //   mapFactory: MessageContent.fromMap,
      // ),
      content: MapSetter.setList<MessageContent>(
        map,
        'content',
        factory: MessageContent.fromMap,
      ),
      toolCalls: MapSetter.setList<ToolCall>(
        map,
        'tool_calls',
        factory: ToolCall.fromMap,
      ),
      toolChoice: MapSetter.set<ToolCall>(
        map,
        'tool_choice',
        factory: ToolCall.fromMap,
      ),
      metadata: MapSetter.setMap<String>(map, 'metadata'),
    );
  }

// This method used to convert the [OpenAIChatCompletionChoiceMessageModel] to a [Map<String, dynamic>] object.
  Map<String, dynamic> toMap() {
    return {
      "role": role.name,
      "content": content?.map((contentItem) => contentItem.toMap()).toList(),
      if (toolCalls != null && role == ChatRole.assistant)
        "tools": toolCalls!.map((toolCall) => toolCall.toMap()).toList(),
      if (name != null) "name": name,
    };
  }

  @override
  String toString() {
    String str = 'OpenAIChatCompletionChoiceMessageModel('
        'role: $role, '
        'content: $content, ';

    if (toolCalls != null) {
      str += 'toolCalls: $toolCalls, ';
    }
    str += ')';

    return str;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.role == role &&
        other.content == content &&
        other.toolCalls == toolCalls;
  }

  /// Converts a response function message to a request function message, so that it can be used in the next request.
  ///
  /// You should pass the response function message's [toolCallId] to this method, since it is required when requesting it.
  RequestFunctionMessage asRequestFunctionMessage({
    required String toolCallId,
  }) {
    return RequestFunctionMessage(
      content: this.content,
      role: this.role,
      toolCallId: toolCallId,
    );
  }
}

/// {@template openai_chat_completion_function_choice_message_model}
/// This represents the message of the [RequestFunctionMessage] model of the OpenAI API, which is used  while using the [OpenAIChat] methods, precisely to send a response function message as a request function message for next requests.
/// {@endtemplate}
base class RequestFunctionMessage extends Message {
  /// The [toolCallId] of the message.
  final String toolCallId;

  /// {@macro openai_chat_completion_function_choice_message_model}
  RequestFunctionMessage({
    required super.role,
    required super.content,
    required this.toolCallId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "role": role.name,
      "content": content?.map((toolCall) => toolCall.toMap()).toList(),
      "tool_call_id": toolCallId,
    };
  }

  //! Does this needs fromMap method?
}
