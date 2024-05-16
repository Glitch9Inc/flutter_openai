import 'dart:io';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

const int DEFAULT_QUERY_LIMIT = 20;

@internal
abstract class EndpointInterface {
  /// This getter returns the endpoint of the entity.
  String get endpoint;
}

abstract class RetrieveInterface<T> {
  Future<T> retrieve(String objectId);
}

abstract class ListInterface<T> {
  Future<List<T>> list({
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

abstract class RetrieveContentInterface {
  Future retrieveContent(
    String fileId, {
    http.Client? client,
  });
}

abstract class UploadInterface {
  Future<FileObject> upload({
    required File file,
    required String purpose,
  });
}
