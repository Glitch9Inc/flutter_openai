import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/flutter_openai_internal.dart';
import 'package:flutter_openai/src/core/models/message/attachment.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/core/requests/interfaces/message_interface.dart';
import 'package:flutter_openai/src/core/requests/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class MessageRequest extends MessageInterface {
  @override
  String get endpoint => OpenAI.endpoint.messages;

  @override
  Future<Message> create(
    String threadId, {
    required ChatRole role,
    required List<MessageContent> content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        "role": role.name,
        "content": content.map((p0) => p0.toMap()).toList(),
        if (attachments != null) "attachments": attachments.map((p0) => p0.toMap()).toList(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Message.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<Message> createWithText(
    String threadId, {
    required ChatRole role,
    required String content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        "role": role.name,
        "content": content,
        if (attachments != null) "attachments": attachments.map((p0) => p0.toMap()).toList(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Message.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<Message> retrieve(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return RequestUtils.retrieve(formattedEndpoint, (p0) => Message.fromMap(p0), isBeta: true);
  }

  @override
  Future<Query<Message>> list(
    String threadId, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.list(formattedEndpoint, (p0) => Message.fromMap(p0), isBeta: true);
  }

  @override
  Future<Message> modify(
    String threadId, {
    ToolBase? toolResources,
    Map<String, String>? metadata,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Message.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<bool> delete(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return RequestUtils.delete(formattedEndpoint, isBeta: true);
  }
}
