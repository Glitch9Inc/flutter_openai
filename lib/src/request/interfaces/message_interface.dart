import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/models/message/attachment.dart';
import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';
import 'package:http/http.dart' as http;

abstract class MessageInterface
    implements EndpointInterface, MessageListInterface, RetrieveInterface, DeleteInterface {
  // create and modify
  Future<Message> create(
    String threadId, {
    required ChatRole role,
    required MessageContent content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
    http.Client? client,
  });

  Future<Message> createWithText(
    String threadId, {
    required ChatRole role,
    required String content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
    http.Client? client,
  });

  Future<Message> modify(
    String threadId, {
    ToolBase? toolResources,
    Map<String, String>? metadata,
    http.Client? client,
  });
}
