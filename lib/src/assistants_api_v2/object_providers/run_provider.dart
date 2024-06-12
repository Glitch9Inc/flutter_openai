import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/base/assistants_api_provider.dart';

class RunProvider extends AssistantsAPIProvider<Run> {
  RunProvider(super.api, super.logger);

  @override
  Future<Result> createInternal() async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a run.");
    if (api.assistantId.isEmpty)
      throw ArgumentError("assistantId must be provided to create a run.");
    if (api.lastRunRequest == null)
      throw ArgumentError("lastRunRequest must be provided to create a run.");

    var result = await OpenAI.instance.run.create(
      api.threadId,
      assistantId: api.assistantId,
      model: api.lastRunRequest!.model,
      instructions: api.lastRunRequest!.instructions,
      additionalInstructions: api.lastRunRequest!.additionalInstructions,
      metadata: api.lastRunRequest!.metadata,
      stream: api.lastRunRequest!.stream,
      temperature: api.lastRunRequest!.temperature,
      maxPromptTokens: api.lastRunRequest!.maxPromptTokens,
      maxCompletionTokens: api.lastRunRequest!.maxCompletionTokens,
      topP: api.lastRunRequest!.topP,
      toolChoice: api.lastRunRequest!.toolChoice,
      responseFormat: api.lastRunRequest!.responseFormat,
    );

    return ResultObject<Run>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to retrieve a run.");

    var result = await OpenAI.instance.run.retrieve(api.threadId, id);
    if (result == null) return Result.fail();

    return ResultObject<Run>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    throw UnimplementedError();
  }
}
