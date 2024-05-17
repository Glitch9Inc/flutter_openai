import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/convert_utils.dart';

class StepDetails {
  final MessageCreationDetails? messageCreation;
  final ToolCallDetails? toolCalls;

  @override
  int get hashCode => messageCreation.hashCode ^ toolCalls.hashCode;

  const StepDetails({this.messageCreation, this.toolCalls});

  factory StepDetails.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('message_creation')) {
      return StepDetails(
        messageCreation: MessageCreationDetails.fromMap(map),
      );
    } else if (map.containsKey('type') && map['type'] == 'tool_calls') {
      return StepDetails(
        toolCalls: ToolCallDetails.fromMap(map),
      );
    } else {
      throw ArgumentError('Invalid step details type');
    }
  }

  Map<String, dynamic> toMap() {
    if (messageCreation != null) {
      return messageCreation!.toMap();
    } else if (toolCalls != null) {
      return toolCalls!.toMap();
    } else {
      throw ArgumentError('Invalid step details type');
    }
  }

  @override
  String toString() {
    if (messageCreation != null) {
      return 'StepDetails(messageCreation: $messageCreation)';
    } else if (toolCalls != null) {
      return 'StepDetails(toolCalls: $toolCalls)';
    } else {
      return 'StepDetails()';
    }
  }

  @override
  bool operator ==(covariant StepDetails other) {
    if (identical(this, other)) return true;

    return messageCreation == other.messageCreation && toolCalls == other.toolCalls;
  }
}

class MessageCreationDetails {
  final String type;
  final String messageId;

  @override
  int get hashCode => type.hashCode ^ messageId.hashCode;

  const MessageCreationDetails({required this.type, required this.messageId});

  factory MessageCreationDetails.fromMap(Map<String, dynamic> map) {
    return MessageCreationDetails(
      type: map['type'],
      messageId: map['message_creation']['message_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message_creation': {
        'message_id': messageId,
      },
    };
  }

  @override
  String toString() => 'MessageCreationDetails(type: $type, messageId: $messageId)';

  @override
  bool operator ==(covariant MessageCreationDetails other) {
    if (identical(this, other)) return true;

    return other.type == type && other.messageId == messageId;
  }
}

class ToolCallDetails {
  final String type;
  final List<ToolCall> toolCalls;

  @override
  int get hashCode => type.hashCode ^ toolCalls.hashCode;

  const ToolCallDetails({required this.type, required this.toolCalls});

  factory ToolCallDetails.fromMap(Map<String, dynamic> map) {
    return ToolCallDetails(
      type: map['type'],
      toolCalls: ConvertUtils.fromList(
        map['tool_calls'],
        (toolCall) => ToolCall.fromMap(toolCall),
      )!,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'tool_calls': toolCalls,
    };
  }

  @override
  String toString() => 'ToolCallDetails(type: $type, toolCalls: $toolCalls)';

  @override
  bool operator ==(covariant ToolCallDetails other) {
    if (identical(this, other)) return true;
    return other.type == type && other.toolCalls == toolCalls;
  }
}
