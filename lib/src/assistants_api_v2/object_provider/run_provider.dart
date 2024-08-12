import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/base/assistants_api_provider.dart';

class RunProvider extends AssistantsAPIProvider<Run> {
  RunProvider(super.api);

  @override
  Future<Result> createInternal() async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a run.");
    if (api.assistantId.isEmpty) throw ArgumentError("assistantId must be provided to create a run.");
    if (api.lastRunRequest == null) throw ArgumentError("lastRunRequest must be provided to create a run.");

    logger.shout("Creating a run for threadId: ${api.threadId}");
    RunRequest runRef = api.lastRunRequest ?? api.defaultRunRequest;

    String runInstructions = runRef.instructions ?? '';
    if (api.maxRequestLength != -1) runInstructions += " Limit your response to ${api.maxRequestLength} characters.";
    //runInstructions += 'Return the response in json format.';

    var result = await OpenAI.instance.run.create(
      api.threadId,
      assistantId: api.assistantId,
      model: runRef.model,
      instructions: runInstructions,
      additionalInstructions: runRef.additionalInstructions,
      metadata: runRef.metadata,
      stream: runRef.stream,
      temperature: runRef.temperature,
      maxPromptTokens: runRef.maxPromptTokens,
      maxCompletionTokens: runRef.maxCompletionTokens,
      topP: runRef.topP,
      toolChoice: runRef.toolChoice,
      responseFormat: runRef.responseFormat,
    );

    return Result<Run>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to retrieve a run.");

    var result = await OpenAI.instance.run.retrieve(api.threadId, id);
    if (result == null) return Result.fail("Failed to retrieve $id.");

    return Result<Run>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> listInternal(int count) async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a message.");

    var result = await OpenAI.instance.run.list(api.threadId, limit: count);
    if (result.data == null) return Result.fail("Failed to list assistants.");
    return Result<List<Run>>.success(result.data!);
  }
}
