import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';

class RequestUtils {
  static Future<List<T>> list<T>(
    String endpoint,
    T Function(Map<String, dynamic>) create, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder? order,
    QueryCursor? cursor,
    bool isBeta = false,
  }) async {
    return await OpenAIClient.get(
      from: endpoint,
      body: {
        "limit": limit,
        if (order != null) "order": order.getName(),
        if (cursor != null) ...{"after": cursor.after, "before": cursor.before},
      },
      create: (Map<String, dynamic> response) {
        final List dataList = response['data'];

        return dataList.map<T>((e) => create(e as Map<String, dynamic>)).toList();
      },
      isBeta: isBeta,
    );
  }

  static Future<T> retrieve<T>(
    String endpoint,
    T Function(Map<String, dynamic>) create, {
    bool isBeta = false,
  }) async {
    return await OpenAIClient.get(
      from: endpoint,
      create: (Map<String, dynamic> response) {
        return create(response);
      },
      isBeta: isBeta,
    );
  }

  static Future<bool> delete(String endpoint, {bool isBeta = false}) async {
    return await OpenAIClient.delete(
      from: endpoint,
      create: (Map<String, dynamic> response) {
        final bool isDeleted = response["deleted"] as bool;

        return isDeleted;
      },
      isBeta: isBeta,
    );
  }
}
