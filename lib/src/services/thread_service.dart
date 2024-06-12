import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/models_endpoints/message/message.dart';
import 'package:flutter_openai/src/models_endpoints/thread/thread.dart';
import 'package:flutter_openai/src/openai.dart';
import 'package:flutter_openai/src/services/interfaces/thread_interface.dart';
import 'package:flutter_openai/src/utils/openai_requester.dart';

interface class ThreadService implements ThreadInterface {
  @override
  String get endpoint => OpenAI.endpoint.thread;

  @override
  Future<Thread> create({
    List<Message>? messages,
    ToolCall? toolResources,
    Map<String, String>? metadata,
  }) {
    return OpenAIClient.post<Thread>(
      to: endpoint,
      body: {
        if (messages != null) "messages": messages.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Thread.fromMap(p0),
      isBeta: true,
    );
  }

  @override
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

  @override
  Future<Thread?> retrieve(String threadId) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.retrieve(formattedEndpoint, (p0) => Thread.fromMap(p0), isBeta: true);
  }

  @override
  Future<bool> delete(String threadId) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.delete(formattedEndpoint, isBeta: true);
  }
}
