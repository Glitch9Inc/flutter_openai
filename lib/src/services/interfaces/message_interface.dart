import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/services/interfaces/shared_interfaces.dart';

abstract class MessageInterface implements EndpointInterface, RetrieveInterface, DeleteInterface {
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
    ToolCall? toolResources,
    Map<String, String>? metadata,
  });

  Future<Query<Message>> list(String threadId);
}
