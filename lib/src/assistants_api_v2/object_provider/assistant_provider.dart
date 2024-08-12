import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/base/assistants_api_provider.dart';
import 'package:flutter_openai/flutter_openai.dart';

class AssistantProvider extends AssistantsAPIProvider<Assistant> {
  AssistantProvider(super.api);

  @override
  Future<Result> createInternal() async {
    StringBuffer sb = StringBuffer();
    sb.write(api.instructions);
    if (api.maxRequestLength != -1) sb.write(" Limit your response to ${api.maxRequestLength} characters.");

    var result = await OpenAI.instance.assistant.create(
      api.model,
      name: api.name,
      description: api.description,
      instructions: sb.toString(),
      tools: api.tools,
      toolResources: api.toolResources,
      temperature: api.temperature,
      topP: api.topP,
      responseFormat: api.responseFormat,
    );

    return Result<Assistant>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    var result = await OpenAI.instance.assistant.retrieve(id);
    if (result == null) return Result.fail("Failed to retrieve $id.");

    return Result<Assistant>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    bool deleted = await OpenAI.instance.assistant.delete(id);
    if (deleted) return Result.success("$id deleted successfully.");

    return Result.fail("Failed to delete $id.");
  }

  @override
  Future<Result> listInternal(int count) async {
    var result = await OpenAI.instance.assistant.list(limit: count);
    if (result.data == null) return Result.fail("Failed to list assistants.");
    return Result<List<Assistant>>.success(result.data!);
  }
}
