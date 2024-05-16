import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/request/interfaces/assistant_interface.dart';
import 'package:flutter_openai/src/request/mixins/list_mixin.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';

import '../../flutter_openai.dart';
import '../core/constants/strings.dart';
import '../core/utils/logger.dart';

interface class AssistantRequest implements AssistantInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.assistant;

  AssistantRequest() {
    OpenAILogger.logEndpoint(endpoint);
  }

  @override
  Future<bool> delete(String assistantId) async {
    return await RequestUtils.delete(endpoint, assistantId);
  }

  @override
  Future<List<AssistantObject>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) {
    return RequestUtils.list<AssistantObject>(
      endpoint: endpoint,
      create: (e) => AssistantObject.fromMap(e),
      limit: limit,
      order: order,
      cursor: cursor,
    );
  }
}
