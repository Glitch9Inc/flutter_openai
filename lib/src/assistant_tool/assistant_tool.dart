import 'dart:async';
import 'dart:convert';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/openai_logger.dart';

export 'package:flutter_openai/src/assistant_tool/assistant_options.dart';
export 'package:flutter_openai/src/assistant_tool/run_options.dart';

abstract class AssistantTool<TToolResponse> {
  static const int INITIAL_DELAY_MILLIS = 1000;
  static const int REQUEST_DELAY_MILLIS = 2000;

  // Default values
  static const GPTModel DEFAULT_MODEL = GPTModel.GPT4o;
  static const int DEFAULT_MAX_REQUEST_LENGTH = 1000;
  static const int DEFAULT_MIN_TOKEN_REQUIREMENT = 500;
  static const int DEFAULT_INITIAL_DELAY_FOR_STATE_CHECK_SEC = 5;
  static const int DEFAULT_RECURRING_STATE_CHECK_INTERVAL_SEC = 2;
  static const int DEFAULT_OPERATION_TIMEOUT_SEC = 60;
  static const int DEFAULT_ASSISTANTS_FETCH_COUNT = 20;

  // Configurations
  final int minTokenRequirement;
  final AssistantOptions assistantOptions;
  final RunOptions? runOptions;
  final int maxRequestLength;
  final int initialDelayForStateCheckSec;
  final int recurringStateCheckIntervalSec;
  final int operationTimeoutSec;
  final int assistantsFetchCount;

  // Properties
  GPTModel model = DEFAULT_MODEL;
  Assistant? assistant;
  Thread? thread;
  Run? currentRun;
  String? _toolName;
  String? _threadId;
  String? _assistantId;
  DateTime _lastRequestTime = DateTime.now();

  AssistantTool(
    this.assistantOptions, {
    this.minTokenRequirement = DEFAULT_MIN_TOKEN_REQUIREMENT,
    this.maxRequestLength = DEFAULT_MAX_REQUEST_LENGTH,
    this.initialDelayForStateCheckSec = DEFAULT_INITIAL_DELAY_FOR_STATE_CHECK_SEC,
    this.recurringStateCheckIntervalSec = DEFAULT_RECURRING_STATE_CHECK_INTERVAL_SEC,
    this.operationTimeoutSec = DEFAULT_OPERATION_TIMEOUT_SEC,
    this.assistantsFetchCount = DEFAULT_ASSISTANTS_FETCH_COUNT,
    this.runOptions,
  }) {
    String toolName = runtimeType.toString();
    _toolName = toolName;
    model = assistantOptions.model;
    _threadId = "$toolName.ThreadId";
    _assistantId = "$toolName.AssistantId";
  }

  Future<void> initialize() async {
    try {
      thread = await _getThread();

      await Future.delayed(const Duration(milliseconds: INITIAL_DELAY_MILLIS));

      assistant = await _getAssistant();

      if (assistant == null || thread == null) {
        throw Exception("Initialization failed");
      }

      _assistantId = assistant!.id;
      _threadId = thread!.id;

      await onInitialize();
    } catch (e) {
      print("Error initializing assistant tool: $e");
    }
  }

  /// Callback for when the assistant tool is initialized
  Future<void> onInitialize();

  /// Validate the tokens
  bool validateTokens(int minTokens);

  /// Remove line breaks from the text
  String removeLineBreaks(String text) => text.replaceAll(RegExp(r'\n|\r'), '');

  /// Parse the result of the run
  TToolResponse createResponse(Map<String, dynamic>? runResultJson);

  /// Callback for when the tokens are used
  void onTokensUsed(Usage usage);

  Future<List<TToolResponse>?> request(
    String promptText, {
    String? additionalInstruction,
    Function(String)? onRequestPrepared,
  }) async {
    if (promptText.isEmpty) {
      print("[$_toolName|Request] The input text is empty.");

      return null;
    }

    print("[$_toolName|Request] Requesting with input: $promptText");

    // Validate tokens (Assuming method exists)
    if (!validateTokens(minTokenRequirement)) return null;

    // Check if request is too soon
    if (DateTime.now().difference(_lastRequestTime) <
        Duration(milliseconds: REQUEST_DELAY_MILLIS)) {
      print("[$_toolName|Request] The request is too fast. Please wait for a while.");

      return null;
    }

    _lastRequestTime = DateTime.now();
    promptText = removeLineBreaks(promptText);

    if (thread == null) {
      print("Thread is not initialized.");

      return null;
    }

    try {
      await OpenAI.instance.message.createWithText(
        thread!.id,
        role: ChatRole.user,
        content: promptText,
      );
    } catch (e) {
      print("Error creating assistant message: $e");

      return null;
    }

    onRequestPrepared?.call(promptText);

    if (currentRun != null && currentRun!.status == RunStatus.completed) {
      await _waitForRunStatusChange(RunStatus.completed);
    }

    currentRun = await OpenAI.instance.run.create(
      thread!.id,
      assistantId: assistant!.id,
      additionalInstruction: additionalInstruction,
    );

    if (currentRun == null) {
      OpenAILogger.errorCreatingObject("run");

      return null;
    }

    currentRun = await _waitForRunStatusChange(RunStatus.requires_action);
    if (currentRun == null) return null;

    List<TToolResponse>? functionResult = _retrieveRunResult();
    if (functionResult == null) return null;

    _completeRun(currentRun!); // Handle usage and complete the run if necessary

    return functionResult;
  }

  Future<Thread?> _getThread() async {
    if (_threadId != null) {
      Thread? thread = await OpenAI.instance.thread.retrieve(_threadId!);
      if (thread != null) return thread;
      await Future.delayed(Duration(milliseconds: INITIAL_DELAY_MILLIS));
    }

    return await OpenAI.instance.thread.create();
  }

  Future<Assistant?> _getAssistant() async {
    Assistant? assistant;
    if (_assistantId != null) {
      assistant = await OpenAI.instance.assistant.retrieve(_assistantId!);
      if (assistant != null) return assistant;
      await Future.delayed(Duration(milliseconds: INITIAL_DELAY_MILLIS));
    }

    return await _createAssistant();
  }

  Future<Assistant?> _createAssistant() async {
    StringBuffer sb = StringBuffer();
    sb.write(assistantOptions.instruction);
    sb.write(" Limit your response to $maxRequestLength characters.");

    return await OpenAI.instance.assistant.create(
      model,
      name: assistantOptions.name,
      description: assistantOptions.description,
      instruction: sb.toString(),
      tools: assistantOptions.tools,
      toolResources: assistantOptions.toolResources,
      temperature: assistantOptions.temperature,
      topP: assistantOptions.topP,
      responseFormat: assistantOptions.responseFormat,
    );
  }

  /// Wait for the run status to change
  Future<Run?> _waitForRunStatusChange(RunStatus statusToWaitFor) async {
    DateTime endTime = DateTime.now().add(Duration(seconds: operationTimeoutSec));
    await Future.delayed(Duration(seconds: initialDelayForStateCheckSec));

    while (DateTime.now().isBefore(endTime)) {
      // Simulating retrieving the run status
      // Assume you have a method to check the status of the run
      currentRun = await OpenAI.instance.run.retrieve(thread!.id, currentRun!.id) ?? currentRun;

      if (currentRun != null && currentRun!.status == statusToWaitFor) {
        return currentRun;
      }

      await Future.delayed(Duration(seconds: recurringStateCheckIntervalSec));
    }

    print("Operation timed out after $operationTimeoutSec seconds.");

    return null;
  }

  List<TToolResponse>? _retrieveRunResult() {
    List<ToolCall>? resultToolCalls = currentRun?.requiredAction?.submitToolOutputs.toolCalls;

    if (resultToolCalls == null) {
      return null;
    }

    List<String?> funcArgs =
        resultToolCalls.map((toolCall) => toolCall.function.arguments).toList();

    return funcArgs.map((arg) => createResponse(_parseResult(arg))).toList();
  }

  Map<String, dynamic>? _parseResult(String? runResultJson) {
    if (runResultJson == null) return null;

    return jsonDecode(runResultJson);
  }

  Future<void> _completeRun(Run run) async {
    // Assuming you have a method to complete the run
    try {
      List<ToolOutput>? toolOutputs = currentRun?.requiredAction?.submitToolOutputs.toolCalls
          .where((toolCall) => toolCall.id != null && toolCall.function.arguments != null)
          .map((toolCall) =>
              ToolOutput(toolCallId: toolCall.id!, output: toolCall.function.arguments!))
          .toList();

      currentRun = await OpenAI.instance.run
          .submitToolOutputsToRun(thread!.id, currentRun!.id, toolOutputs: toolOutputs);

      if (currentRun == null) return;

      currentRun = await _waitForRunStatusChange(RunStatus.completed);
      if (currentRun == null) return;
      if (currentRun!.usage != null) {
        onTokensUsed(currentRun!.usage!);
      }

      print("Run completed successfully.");
    } catch (e) {
      print("Failed to complete the run: $e");
    }
  }
}
