import 'package:flutter_openai/openai.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/models/message/message.dart';
import 'package:flutter_openai/src/core/models/thread/thread.dart';
import 'package:flutter_openai/src/core/models/tool/tool_base.dart';
import 'package:flutter_openai/src/core/requests/interfaces/thread_interface.dart';
import 'package:flutter_openai/src/core/requests/utils/request_utils.dart';

interface class ThreadRequest implements ThreadInterface {
  @override
  String get endpoint => OpenAI.endpoint.thread;

  @override
  Future<Thread> create({
    List<Message>? messages,
    ToolBase? toolResources,
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
    ToolBase? toolResources,
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

    return RequestUtils.retrieve(formattedEndpoint, (p0) => Thread.fromMap(p0), isBeta: true);
  }

  @override
  Future<bool> delete(String threadId) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.delete(formattedEndpoint, isBeta: true);
  }
}
