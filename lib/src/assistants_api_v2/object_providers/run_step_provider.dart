import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/base/assistants_api_provider.dart';

class RunStepProvider extends AssistantsAPIProvider<RunStep> {
  RunStepProvider(super.api, super.logger);

  @override
  Future<Result> createInternal() {
    throw UnimplementedError();
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    if (api.threadId.isEmpty)
      throw ArgumentError("threadId must be provided to retrieve a run step.");
    if (api.runId.isEmpty) throw ArgumentError("runId must be provided to retrieve a run step.");

    var result = await OpenAI.instance.runStep.retrieve(api.threadId, api.runId, id);
    if (result == null) return Result.fail();

    return ResultObject<RunStep>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) {
    throw UnimplementedError();
  }
}
