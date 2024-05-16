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
  Future<AssistantObject> create(
    String name,
    List<ToolCall> toolCalls, {
    String? description,
    String? instruction,
    List<String>? fileIds,
    http.Client? client,
  }) async {
    return await OpenAIClient.post(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        "name": name,
        "tool_calls": toolCalls.map((toolCall) => toolCall.toMap()).toList(growable: false),
        if (description != null) "description": description,
        if (instruction != null) "instruction": instruction,
        if (fileIds != null) "file_ids": fileIds,
      },
      onSuccess: (Map<String, dynamic> response) {
        return AssistantObject.fromMap(response);
      },
      client: client,
    );
  }

  @override
  Future<List<AssistantObject>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    http.Client? client,
  }) {
    return RequestUtils.list<AssistantObject>(
      endpoint,
      (e) => AssistantObject.fromMap(e),
      limit: limit,
      order: order,
      cursor: cursor,
      client: client,
    );
  }

  @override
  Future retrieve(String objectId, {http.Client? client}) {
    return RequestUtils.retrieve<AssistantObject>(
      endpoint,
      (e) => AssistantObject.fromMap(e),
      objectId,
      client: client,
    );
  }

  @override
  Future<bool> delete(String assistantId, {http.Client? client}) async {
    return await RequestUtils.delete(endpoint, assistantId, client: client);
  }
}
