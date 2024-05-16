import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';

class RequestUtils {
  static Future<List<T>> list<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder? order,
    QueryCursor? cursor,
  }) async {
    return await OpenAIClient.get(
      from: BaseApiUrlBuilder.build(endpoint),
      body: {
        "limit": limit,
        if (order != null) "order": order.getName(),
        if (cursor != null) ...{"after": cursor.after, "before": cursor.before},
      },
      onSuccess: (Map<String, dynamic> response) {
        final List dataList = response['data'];

        return dataList.map<T>((e) => create(e as Map<String, dynamic>)).toList();
      },
    );
  }

  static Future<bool> delete(String endpoint, String objectId) async {
    return await OpenAIClient.delete(
      from: BaseApiUrlBuilder.build(endpoint + "/$objectId"),
      onSuccess: (Map<String, dynamic> response) {
        final bool isDeleted = response["deleted"] as bool;

        return isDeleted;
      },
    );
  }
}
