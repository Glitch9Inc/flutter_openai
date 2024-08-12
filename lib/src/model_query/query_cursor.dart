/// A cursor for use in pagination.
export 'package:flutter_openai/src/model_query/query_cursor.dart';
export 'package:flutter_openai/src/model_query/query_order.dart';

const DEFAULT_QUERY_LIMIT = 20;

class QueryCursor {
  /// An object ID that defines your place in the list.
  /// For instance, if you make a list request and receive 100 objects,
  /// ending with obj_foo, your subsequent call can include after=obj_foo
  /// in order to fetch the next page of the list.
  final String? after;

  /// An object ID that defines your place in the list.
  /// For instance, if you make a list request and receive 100 objects,
  /// ending with obj_foo, your subsequent call can include before=obj_foo
  /// in order to fetch the previous page of the list.
  final String? before;

  QueryCursor({this.after, this.before});
}
