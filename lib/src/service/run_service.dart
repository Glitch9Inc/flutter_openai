import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:http/src/client.dart';

interface class RunService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.runs;

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
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIClient.post<Run>(
      to: formattedEndpoint,
      body: {
        "assistant_id": assistantId,
        if (model != null) "model": model.value,
        if (instructions != null) "instructions": instructions,
        if (additionalInstructions != null) "additional_instructions": additionalInstructions,
        if (additionalMessages != null) "additional_messages": additionalMessages.map((p0) => p0.toMap()).toList(),
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

  Future<Run> createThreadAndRun({
    required String assistantId,
    Thread? thread,
    GPTModel? model,
    String? instruction,
    List<ToolCall>? tools,
    ToolResources? toolResources,
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
        if (model != null) "model": model.value,
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

  Future<Query<Run>> list(
    String threadId, {
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    Client? client,
  }) {
    final formattedEndpoint = endpoint.replaceAll("{thread_id}", threadId);

    return OpenAIRequester.list(formattedEndpoint, (p0) => Run.fromMap(p0), isBeta: true);
  }

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

  Future<Run?> retrieve(String threadId, String runId) async {
    String ep = '/threads/{thread_id}/runs/{run_id}';
    final formattedEndpoint = ep.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);
    var resultRun = await OpenAIRequester.retrieve(formattedEndpoint, (p0) => Run.fromMap(p0), isBeta: true);
    return resultRun;
  }

  Future<Run> submitToolOutputsToRun(
    String threadId,
    String runId, {
    List<ToolOutput>? output,
    bool? stream,
  }) {
    String ep = '/threads/{thread_id}/runs/{run_id}';
    final formattedEndpoint = ep.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return OpenAIClient.post<Run>(
      to: formattedEndpoint,
      body: {
        if (output != null) "tool_outputs": output.map((p0) => p0.toMap()).toList(),
        if (stream != null) "stream": stream,
      },
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }

  Future<Run?> cancel(String threadId, String runId) async {
    final formattedEndpoint =
        '/threads/{thread_id}/runs/{run_id}/cancel'.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return await OpenAIClient.post<Run?>(
      to: formattedEndpoint,
      create: (p0) => Run.fromMap(p0),
      isBeta: true,
    );
  }
}
