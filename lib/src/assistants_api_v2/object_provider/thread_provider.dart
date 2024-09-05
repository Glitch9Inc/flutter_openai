import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/base/assistants_api_provider.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

class ThreadProvider extends AssistantsAPIProvider<Thread> {
  ThreadProvider(super.api);

  @override
  Future<Result> createInternal() async {
    var result = await OpenAI.instance.thread.create();

    return Result<Thread>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    var result = await OpenAI.instance.thread.retrieve(id);
    if (result == null) return Result.error("Failed to retrieve $id.");

    return Result<Thread>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    bool deleted = await OpenAI.instance.thread.delete(id);
    if (deleted) return Result.success("$id deleted successfully.");

    return Result.error("Failed to delete $id.");
  }

  @override
  Future<Result> listInternal(int count) async {
    throw UnimplementedError();
  }
}
