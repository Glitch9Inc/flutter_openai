import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';
import 'package:http/http.dart' as http;

import '../../core/models/tool/tool_choice.dart';

abstract class RunInterface
    implements EndpointInterface, RunListInterface, RunRetrieveInterface, RunCancelInterface {
  Future<Run> create(
    String threadId, {
    required String assistantId,
    GPTModel? model,
    String? instruction,
    String? additionalInstruction,
    List<Message>? additionalMessages,
    List<ToolBase>? tools,
    Map<String, String>? metadata,
    bool? stream,
    double? temperature,
    double? maxPromptTokens,
    double? maxCompletionTokens,
    double? topP,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    http.Client? client,
  });

  Future<Run> createThreadAndRun({
    required String assistantId,
    Thread? thread,
    GPTModel? model,
    String? instruction,
    List<ToolBase>? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    bool? stream,
    double? temperature,
    double? maxPromptTokens,
    double? maxCompletionTokens,
    double? topP,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    http.Client? client,
  });

  Future<Run> modify(
    String threadId,
    String runId, {
    Map<String, String>? metadata,
    http.Client? client,
  });

  Future<Run> submitToolOutputsToRun(
    String threadId,
    String runId, {
    List<ToolOutput>? toolOutputs,
    bool? stream,
    http.Client? client,
  });
}
