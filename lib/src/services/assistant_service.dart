import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

import 'interfaces/assistant_interface.dart';

interface class AssistantService implements AssistantInterface {
  @override
  String get endpoint => OpenAI.endpoint.assistant;

  AssistantService() {
    OpenAILogger.logEndpoint(endpoint);
  }

  @override
  Future<Assistant> create(
    GPTModel model, {
    String? name,
    String? description,
    String? instructions,
    List<ToolCall>? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    ResponseFormat? responseFormat,
  }) {
    return OpenAIClient.post<Assistant>(
      to: endpoint,
      body: {
        "model": model.value,
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (instructions != null) "instructions": instructions,
        if (tools != null) "tools": tools.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (responseFormat != null) "response_format": responseFormat.toStringOrMap(),
      },
      create: (Map<String, dynamic> response) {
        return Assistant.fromMap(response);
      },
      isBeta: true,
    );
  }

  @override
  Future<Assistant> modify(
    String assistantId, {
    GPTModel? model,
    String? name,
    String? description,
    String? instruction,
    List? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    ResponseFormat? responseFormat,
  }) {
    String formattedEndpoint = "$endpoint/$assistantId";

    return OpenAIClient.post<Assistant>(
      to: formattedEndpoint,
      body: {
        if (model != null) "model": model.value,
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (instruction != null) "instruction": instruction,
        if (tools != null) "tools": tools.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (responseFormat != null) "response_format": responseFormat.toStringOrMap(),
      },
      create: (Map<String, dynamic> response) {
        return Assistant.fromMap(response);
      },
      isBeta: true,
    );
  }

  @override
  Future<Query<Assistant>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) {
    return OpenAIRequester.list<Assistant>(
      endpoint,
      (e) => Assistant.fromMap(e),
      limit: limit,
      order: order,
      cursor: cursor,
      isBeta: true,
    );
  }

  @override
  Future<Assistant?> retrieve(String assistantId) {
    String formattedEndpoint = "$endpoint/$assistantId";

    return OpenAIRequester.retrieve<Assistant>(
      formattedEndpoint,
      (e) => Assistant.fromMap(e),
      isBeta: true,
    );
  }

  @override
  Future<bool> delete(String assistantId) async {
    String formattedEndpoint = "$endpoint/$assistantId";

    return await OpenAIRequester.delete(formattedEndpoint, isBeta: true);
  }
}
