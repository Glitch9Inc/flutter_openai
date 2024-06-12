import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/services/interfaces/message_interface.dart';
import 'package:http/src/client.dart';

interface class MessageService extends MessageInterface {
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

    return OpenAIRequester.retrieve(formattedEndpoint, (p0) => Message.fromMap(p0), isBeta: true);
  }

  @override
  Future<Query<Message>> list(
    String threadId, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.list(formattedEndpoint, (p0) => Message.fromMap(p0), isBeta: true);
  }

  @override
  Future<Message> modify(
    String threadId, {
    ToolCall? toolResources,
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

    return OpenAIRequester.delete(formattedEndpoint, isBeta: true);
  }
}
