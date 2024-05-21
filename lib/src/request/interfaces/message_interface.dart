import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/models/message/attachment.dart';
import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';

abstract class MessageInterface
    implements EndpointInterface, MessageListInterface, RetrieveInterface, DeleteInterface {
  // create and modify
  Future<Message> create(
    String threadId, {
    required ChatRole role,
    required List<MessageContent> content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
  });

  Future<Message> createWithText(
    String threadId, {
    required ChatRole role,
    required String content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
  });

  Future<Message> modify(
    String threadId, {
    ToolBase? toolResources,
    Map<String, String>? metadata,
  });
}
