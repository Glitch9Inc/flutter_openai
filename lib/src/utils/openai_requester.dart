import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

class OpenAIRequester {
  static Future<Query<T>> list<T>(
    String endpoint,
    T Function(Map<String, dynamic>) factory, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder? order,
    QueryCursor? cursor,
    bool isBeta = false,
  }) async {
    return await OpenAIClient.get(
      endpoint: endpoint,
      body: {
        "limit": limit,
        if (order != null) "order": order.getName(),
        if (cursor != null) ...{"after": cursor.after, "before": cursor.before},
      },
      factory: (Map<String, dynamic> response) {
        // final List dataList = response['data'];

        // return dataList.map<T>((e) => create(e as Map<String, dynamic>)).toList();
        return Query.fromMap(response, factory: factory);
      },
      isBeta: isBeta,
    );
  }

  static Future<T> retrieve<T>(
    String endpoint,
    T Function(Map<String, dynamic>) factory, {
    bool isBeta = false,
  }) async {
    return await OpenAIClient.get(
      endpoint: endpoint,
      factory: (Map<String, dynamic> response) {
        return factory(response);
      },
      isBeta: isBeta,
    );
  }

  static Future<bool> delete(String endpoint, {bool isBeta = false}) async {
    return await OpenAIClient.delete(
      endpoint: endpoint,
      factory: (Map<String, dynamic> response) {
        final bool isDeleted = response["deleted"] as bool;

        return isDeleted;
      },
      isBeta: isBeta,
    );
  }

  static Future<T> cancel<T>(
    String endpoint,
    T Function(Map<String, dynamic>) factory, {
    bool isBeta = false,
  }) async {
    return await OpenAIClient.delete(
      endpoint: endpoint,
      factory: (Map<String, dynamic> response) {
        return factory(response);
      },
      isBeta: isBeta,
    );
  }
}
