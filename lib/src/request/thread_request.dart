import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/constants/strings.dart';
import 'package:flutter_openai/src/core/models/message/message.dart';
import 'package:flutter_openai/src/core/models/thread/thread.dart';
import 'package:flutter_openai/src/core/models/tool/tool_resources.dart';
import 'package:flutter_openai/src/request/interfaces/thread_interface.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class ThreadRequest implements ThreadInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.thread;

  @override
  Future<Thread> create({
    List<Message>? messages,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    Client? client,
  }) {
    return OpenAIClient.post<Thread>(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        if (messages != null) "messages": messages.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      onSuccess: (p0) => Thread.fromMap(p0),
      client: client,
    );
  }

  @override
  Future<Thread> modify(
    String threadId, {
    ToolResources? toolResources,
    Map<String, String>? metadata,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Thread>(
      to: BaseApiUrlBuilder.build(formattedEndpoint),
      body: {
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      onSuccess: (p0) => Thread.fromMap(p0),
      client: client,
    );
  }

  @override
  Future<Thread?> retrieve(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.retrieve(formattedEndpoint, (p0) => Thread.fromMap(p0));
  }

  @override
  Future<bool> delete(String threadId, {Client? client}) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.delete(formattedEndpoint);
  }
}
