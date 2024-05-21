import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:meta/meta.dart';

export 'package:flutter_openai/src/core/models/export.dart';

/// This getter returns the endpoint of the entity.
@internal
abstract class EndpointInterface {
  String get endpoint;
}

abstract class RetrieveInterface<T> {
  Future<T?> retrieve(String objectId);
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

abstract class RunRetrieveInterface<Run> {
  Future<Run?> retrieve(String threadId, String runId);
}

abstract class MessageListInterface<Message> {
  Future<List<Message>> list(String threadId);
}

abstract class RunListInterface<Run> {
  Future<List<Run>> list(String threadId);
}

abstract class RunCancelInterface<Run> {
  Future<Run?> cancel(String threadId, String runId);
}

abstract class RunStepListInterface<RunStep> {
  Future<List<RunStep>> list(String threadId, String runId);
}

abstract class RunStepRetrieveInterface<RunStep> {
  Future<RunStep?> retrieve(String threadId, String runId, String stepId);
}
