import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/requests/interfaces/shared_interfaces.dart';

import '../../models/tool/tool_choice.dart';

abstract class RunInterface implements EndpointInterface {
  Future<Run> create(
    String threadId, {
    required String assistantId,
    GPTModel? model,
    String? instructions,
    String? additionalInstructions,
    List<Message>? additionalMessages,
    List<ToolCall>? tools,
    Map<String, String>? metadata,
    bool? stream,
    double? temperature,
    double? maxPromptTokens,
    double? maxCompletionTokens,
    double? topP,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
  });

  Future<Run> createThreadAndRun({
    required String assistantId,
    Thread? thread,
    GPTModel? model,
    String? instruction,
    List<ToolCall>? tools,
    ToolResource? toolResources,
    Map<String, String>? metadata,
    bool? stream,
    double? temperature,
    double? maxPromptTokens,
    double? maxCompletionTokens,
    double? topP,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
  });

  Future<Run> modify(
    String threadId,
    String runId, {
    Map<String, String>? metadata,
  });

  Future<Run> submitToolOutputsToRun(
    String threadId,
    String runId, {
    List<ToolOutput>? toolOutputs,
    bool? stream,
  });

  Future<Query<Run>> list(String threadId);
  Future<Run?> retrieve(String threadId, String runId);
  Future<bool> cancel(String threadId, String runId);
}
