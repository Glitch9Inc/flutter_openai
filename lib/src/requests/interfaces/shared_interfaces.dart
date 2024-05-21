import 'package:flutter_openai/src/query/query.dart';
import 'package:flutter_openai/src/query/query_cursor.dart';
import 'package:meta/meta.dart';

export 'package:flutter_openai/src/models/export.dart';

/// This getter returns the endpoint of the entity.
@internal
abstract class EndpointInterface {
  String get endpoint;
}

abstract class RetrieveInterface<T> {
  Future<T?> retrieve(String objectId);
}

abstract class ListInterface<T> {
  Future<Query<T>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  });
}

abstract class DeleteInterface {
  Future<bool> delete(String objectId);
}

abstract class CancelInterface<T> {
  Future<T> cancel(String objectId);
}
