import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:http/http.dart' as http;

class RequestUtils {
  static Future<List<T>> list<T>(
    String endpoint,
    T Function(Map<String, dynamic>) create, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder? order,
    QueryCursor? cursor,
    http.Client? client,
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
      client: client,
    );
  }

  static Future<T> retrieve<T>(
    String endpoint,
    T Function(Map<String, dynamic>) create, {
    http.Client? client,
  }) async {
    return await OpenAIClient.get(
      from: BaseApiUrlBuilder.build(endpoint),
      onSuccess: (Map<String, dynamic> response) {
        return create(response);
      },
      client: client,
    );
  }

  static Future<bool> delete(String endpoint, {http.Client? client}) async {
    return await OpenAIClient.delete(
      from: BaseApiUrlBuilder.build(endpoint),
      onSuccess: (Map<String, dynamic> response) {
        final bool isDeleted = response["deleted"] as bool;

        return isDeleted;
      },
      client: client,
    );
  }
}
