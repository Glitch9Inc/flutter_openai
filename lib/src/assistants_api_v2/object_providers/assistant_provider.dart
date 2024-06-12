import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/base/assistants_api_provider.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

class AssistantProvider extends AssistantsAPIProvider<Assistant> {
  AssistantProvider(super.api, super.logger);

  @override
  Future<Result> createInternal() async {
    StringBuffer sb = StringBuffer();
    sb.write(api.instructions);
    if (api.maxRequestLength != -1)
      sb.write(" Limit your response to ${api.maxRequestLength} characters.");

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

    return ResultObject<Assistant>.success(result);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    var result = await OpenAI.instance.assistant.retrieve(id);
    if (result == null) return Result.fail();

    return ResultObject<Assistant>.success(result);
  }

  @override
  Future<Result> deleteInternal(String id) async {
    bool deleted = await OpenAI.instance.assistant.delete(id);
    if (deleted) return Result.success();

    return Result.fail();
  }
}
