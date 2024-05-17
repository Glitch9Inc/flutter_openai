import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/constants/strings.dart';
import 'package:flutter_openai/src/core/enum.dart';
import 'package:flutter_openai/src/core/models/message/attachment.dart';
import 'package:flutter_openai/src/core/models/message/message.dart';
import 'package:flutter_openai/src/core/models/tool/tool_resources.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/request/interfaces/message_interface.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class MessageRequest extends MessageInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.messages;

  @override
  Future<Message> create(
    String threadId, {
    required ChatRole role,
    required MessageContent content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        "role": role,
        "content": content.toMap(),
        if (attachments != null) "attachments": attachments.map((p0) => p0.toMap()).toList(),
        if (metadata != null) "metadata": metadata,
      },
      onSuccess: (p0) => Message.fromMap(p0),
      client: client,
    );
  }

  @override
  Future<Message> createWithText(
    String threadId, {
    required ChatRole role,
    required String content,
    List<Attachment>? attachments,
    Map<String, String>? metadata,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        "role": role,
        "content": MessageContent.text(content).toMap(),
        if (attachments != null) "attachments": attachments.map((p0) => p0.toMap()).toList(),
        if (metadata != null) "metadata": metadata,
      },
      onSuccess: (p0) => Message.fromMap(p0),
      client: client,
    );
  }

  @override
  Future<Message> retrieve(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return RequestUtils.retrieve(formattedEndpoint, (p0) => Message.fromMap(p0));
  }

  @override
  Future<List<Message>> list(
    String threadId, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.list(formattedEndpoint, (p0) => Message.fromMap(p0));
  }

  @override
  Future<Message> modify(
    String threadId, {
    ToolResources? toolResources,
    Map<String, String>? metadata,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return OpenAIClient.post<Message>(
      to: formattedEndpoint,
      body: {
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      onSuccess: (p0) => Message.fromMap(p0),
      client: client,
    );
  }

  @override
  Future<bool> delete(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{message_id}", threadId);

    return RequestUtils.delete(formattedEndpoint);
  }
}
