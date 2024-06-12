import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/base/assistants_api_provider.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

class ThreadProvider extends AssistantsAPIProvider<Thread> {
  ThreadProvider(super.api, super.logger);

  @override
  Future<Result> createInternal() async {
    var result = await OpenAI.instance.thread.create();

    return ResultObject<Thread>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    var result = await OpenAI.instance.thread.retrieve(id);
    if (result == null) return Result.fail();

    return ResultObject<Thread>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    bool deleted = await OpenAI.instance.thread.delete(id);
    if (deleted) return Result.success();

    return Result.fail();
  }
}
