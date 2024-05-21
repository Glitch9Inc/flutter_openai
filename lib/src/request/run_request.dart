import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/flutter_openai_internal.dart';
import 'package:flutter_openai/src/core/models/tool/tool_choice.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/request/interfaces/run_interface.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class RunRequest implements RunInterface {
  @override
  String get endpoint => OpenAI.endpoint.runs;

  @override
  Future<Run> create(
    String threadId, {
    required String assistantId,
    GPTModel? model,
    String? instructions,
    String? additionalInstructions,
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
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Run>(
      to: formattedEndpoint,
      body: {
        "assistant_id": assistantId,
        if (model != null) "model": MapSetter.fromGPTModel(model),
        if (instructions != null) "instructions": instructions,
        if (additionalInstructions != null) "additional_instructions": additionalInstructions,
        if (additionalMessages != null)
          "additional_messages": additionalMessages.map((p0) => p0.toMap()).toList(),
        if (tools != null) "tools": tools.map((p0) => p0.toMap()).toList(),
        if (metadata != null) "metadata": metadata,
        if (stream != null) "stream": stream,
        if (temperature != null) "temperature": temperature,
        if (maxPromptTokens != null) "max_prompt_tokens": maxPromptTokens,
        if (maxCompletionTokens != null) "max_completion_tokens": maxCompletionTokens,
        if (topP != null) "top_p": topP,
        if (toolChoice != null) "tool_choice": toolChoice.toStringOrMap(),
        if (responseFormat != null) "response_format": responseFormat.toStringOrMap(),
      },
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<Run> createThreadAndRun({
    required String assistantId,
    Thread? thread,
    GPTModel? model,
    String? instruction,
    List<ToolBase>? tools,
    ToolResource? toolResources,
    Map<String, String>? metadata,
    bool? stream,
    double? temperature,
    double? maxPromptTokens,
    double? maxCompletionTokens,
    double? topP,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
  }) {
    String endpoint = '/threads/runs';

    return OpenAIClient.post<Run>(
      to: endpoint,
      body: {
        "assistant_id": assistantId,
        if (thread != null) "thread": thread.toMap(),
        if (model != null) "model": MapSetter.fromGPTModel(model),
        if (instruction != null) "instruction": instruction,
        if (tools != null) "tools": tools.map((p0) => p0.toMap()).toList(),
        if (toolResources != null) "tool_resources": toolResources.toMap(),
        if (metadata != null) "metadata": metadata,
        if (stream != null) "stream": stream,
        if (temperature != null) "temperature": temperature,
        if (maxPromptTokens != null) "max_prompt_tokens": maxPromptTokens,
        if (maxCompletionTokens != null) "max_completion_tokens": maxCompletionTokens,
        if (topP != null) "top_p": topP,
        if (toolChoice != null) "tool_choice": toolChoice.toStringOrMap(),
        if (responseFormat != null) "response_format": responseFormat.toStringOrMap(),
      },
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<Query<Run>> list(
    String threadId, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return RequestUtils.list(formattedEndpoint, (p0) => Run.fromMap(p0), isBeta: true);
  }

  @override
  Future<Run> modify(
    String threadId,
    String runId, {
    Map<String, String>? metadata,
  }) {
    String ep = '/threads/{thread_id}/runs/{run_id}';
    final formattedEndpoint = ep.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return OpenAIClient.post<Run>(
      to: formattedEndpoint,
      body: {
        if (metadata != null) "metadata": metadata,
      },
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<Run?> retrieve(String threadId, String runId, {Client? client}) {
    String ep = '/threads/{thread_id}/runs/{run_id}';
    final formattedEndpoint = ep.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return RequestUtils.retrieve(formattedEndpoint, (p0) => Run.fromMap(p0), isBeta: true);
  }

  @override
  Future<Run> submitToolOutputsToRun(
    String threadId,
    String runId, {
    List<ToolOutput>? toolOutputs,
    bool? stream,
  }) {
    String ep = '/threads/{thread_id}/runs/{run_id}';
    final formattedEndpoint = ep.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return OpenAIClient.post<Run>(
      to: formattedEndpoint,
      body: {
        if (toolOutputs != null) "tool_outputs": toolOutputs.map((p0) => p0.toMap()).toList(),
        if (stream != null) "stream": stream,
      },
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }

  @override
  Future<bool> cancel(String threadId, String runId) {
    final formattedEndpoint =
        endpoint.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return RequestUtils.delete(formattedEndpoint, isBeta: true);
  }
}
