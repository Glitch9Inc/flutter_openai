import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/http.dart' as http;

import '../../flutter_openai.dart';
import '../core/constants/strings.dart';
import '../core/utils/logger.dart';
import 'interfaces/assistant_interface.dart';

interface class AssistantRequest implements AssistantInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.assistant;

  AssistantRequest() {
    OpenAILogger.logEndpoint(endpoint);
  }

  @override
  Future<Assistant> create(
    GPTModel model, {
    String? name,
    String? description,
    String? instruction,
    List<ToolResources>? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    String? responseFormat,
    http.Client? client,
  }) {
    return OpenAIClient.post<Assistant>(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        "model": getName(model),
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (instruction != null) "instruction": instruction,
        if (tools != null) "tools": tools.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (responseFormat != null) "response_format": responseFormat,
      },
      onSuccess: (Map<String, dynamic> response) {
        return Assistant.fromMap(response);
      },
      client: client,
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
    String? responseFormat,
    http.Client? client,
  }) {
    String formattedEndpoint = "$endpoint/$assistantId";

    return OpenAIClient.post<Assistant>(
      to: BaseApiUrlBuilder.build(formattedEndpoint),
      body: {
        if (model != null) "model": getName(model),
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (instruction != null) "instruction": instruction,
        if (tools != null) "tools": tools.map((item) => item.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
        if (temperature != null) "temperature": temperature,
        if (topP != null) "top_p": topP,
        if (responseFormat != null) "response_format": responseFormat,
      },
      onSuccess: (Map<String, dynamic> response) {
        return Assistant.fromMap(response);
      },
      client: client,
    );
  }

  @override
  Future<List<Assistant>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    http.Client? client,
  }) {
    return RequestUtils.list<Assistant>(
      endpoint,
      (e) => Assistant.fromMap(e),
      limit: limit,
      order: order,
      cursor: cursor,
      client: client,
    );
  }

  @override
  Future<Assistant?> retrieve(String assistantId, {http.Client? client}) {
    String formattedEndpoint = "$endpoint/$assistantId";

    return RequestUtils.retrieve<Assistant>(
      formattedEndpoint,
      (e) => Assistant.fromMap(e),
      client: client,
    );
  }

  @override
  Future<bool> delete(String assistantId, {http.Client? client}) async {
    String formattedEndpoint = "$endpoint/$assistantId";

    return await RequestUtils.delete(formattedEndpoint, client: client);
  }
}
