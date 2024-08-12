import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

interface class ThreadService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.thread;

  Future<Thread> create({
    List<Message>? messages,
    ToolCall? toolResources,
    Map<String, String>? metadata,
  }) {
    return OpenAIClient.post<Thread>(
      to: '/threads',
      body: {
        if (messages != null) "messages": messages.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Thread.fromMap(p0),
      isBeta: true,
    );
  }

  Future<Thread> modify(
    String threadId, {
    ToolCall? toolResources,
    Map<String, String>? metadata,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Thread>(
      to: formattedEndpoint,
      body: {
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Thread.fromMap(p0),
      isBeta: true,
    );
  }

  Future<Thread?> retrieve(String threadId) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.retrieve(formattedEndpoint, (p0) => Thread.fromMap(p0), isBeta: true);
  }

  Future<bool> delete(String threadId) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.delete(formattedEndpoint, isBeta: true);
  }
}
