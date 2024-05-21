import 'dart:async';
import 'dart:convert';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/query/query_cursor.dart';
import 'package:flutter_openai/src/utils/openai_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutter_openai/src/assistant_tool/assistant_options.dart';
export 'package:flutter_openai/src/assistant_tool/run_options.dart';

abstract class AssistantTool<TResult> {
  static const int INITIAL_DELAY_MILLIS = 1000;
  static const int REQUEST_DELAY_MILLIS = 2000;

  // Default values
  static const GPTModel DEFAULT_MODEL = GPTModel.GPT4o;
  static const int DEFAULT_MAX_REQUEST_LENGTH = 1000;
  static const int DEFAULT_MIN_TOKEN_REQUIREMENT = 500;
  static const int DEFAULT_INITIAL_DELAY_FOR_STATE_CHECK_SEC = 4;
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
  SharedPreferences? prefs;
  GPTModel model = DEFAULT_MODEL;
  Assistant? assistant;
  Thread? thread;
  Run? currentRun;
  String? _toolName;
  String? _threadId;
  String? _assistantId;
  DateTime _lastRequestTime = DateTime.now();
  bool _isInitializing = true;
  bool _isInit = false;

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
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    String threadIdKey = "$_toolName.ThreadId";
    String assistantIdKey = "$_toolName.AssistantId";
    if (prefs != null) {
      _threadId = prefs!.getString(threadIdKey);
      _assistantId = prefs!.getString(assistantIdKey);
    }

    thread = await _getThread();
    if (thread == null) {
      _isInitializing = false;
      throw Exception("Unable to get thread");
    }

    assistant = await _getAssistant();

    if (assistant == null) {
      _isInitializing = false;
      throw Exception("Unable to get assistant");
    }

    _assistantId = assistant!.id;
    _threadId = thread!.id;

    await onInit();
    _isInit = true;
    _isInitializing = false;
    print("Assistant tool initialized successfully.");
  }

  /// Callback for when the assistant tool is initialized
  Future<void> onInit();

  /// Validate the tokens
  bool validateTokens(int minTokens);

  /// Remove line breaks from the text
  String removeLineBreaks(String text) => text.replaceAll(RegExp(r'\n|\r'), '');

  /// Parse the result of the run
  TResult createResponse(Map<String, dynamic>? runResultJson);

  /// Callback for when the tokens are used
  void onTokensUsed(Usage usage);

  Future<List<TResult>?> request(
    String promptText, {
    String? additionalInstruction,
    Function(String)? onRequestPrepared,
  }) async {
    try {
      await _validateTool();
    } catch (e) {
      throw Exception(e);
    }

    if (promptText.isEmpty) {
      throw Exception("The input text is empty.");
    }

    print("[$_toolName|Request] Requesting with input: $promptText");

    // Validate tokens (Assuming method exists)
    if (!validateTokens(minTokenRequirement)) return null;

    // Check if request is too soon
    if (DateTime.now().difference(_lastRequestTime) <
        Duration(milliseconds: REQUEST_DELAY_MILLIS)) {
      throw Exception("The request is too fast. Please wait for a while.");
    }

    _lastRequestTime = DateTime.now();
    promptText = removeLineBreaks(promptText);

    try {
      await OpenAI.instance.message.createWithText(
        thread!.id,
        role: ChatRole.user,
        content: promptText,
      );
    } catch (e) {
      throw Exception("Error creating assistant message: $e");
    }

    onRequestPrepared?.call(promptText);

    if (currentRun != null && currentRun!.status == RunStatus.completed) {
      await _waitForRunStatusChange(RunStatus.completed);
    }

    currentRun = await OpenAI.instance.run.create(
      thread!.id,
      assistantId: assistant!.id,
      additionalInstructions: additionalInstruction,
    );

    if (currentRun == null) throw Exception("Error creating run.");
    currentRun = await _waitForRunStatusChange(RunStatus.requires_action);
    if (currentRun == null) throw Exception("Error waiting for run status change.");

    List<TResult>? functionResult = await _retrieveResult();
    if (functionResult == null) throw Exception("Error retrieving run result.");

    _completeRun(currentRun!); // Handle usage and complete the run if necessary

    return functionResult;
  }

  Future<Thread?> _getThread() async {
    if (_threadId != null && !_threadId!.isEmpty) {
      try {
        OpenAILogger.tryingToRetrieveObject("thread");
        thread = await OpenAI.instance.thread.retrieve(_threadId!);
      } catch (e) {
        print("Error retrieving thread: $e");
      }

      if (thread != null) return thread;
      OpenAILogger.failedToRetrieveObject("thread");
      await Future.delayed(Duration(milliseconds: INITIAL_DELAY_MILLIS));
    }

    OpenAILogger.creatingNewObject("thread");

    try {
      return OpenAI.instance.thread.create();
    } catch (e) {
      print("Error creating thread: $e");
    }

    return null;
  }

  Future<void> _validateTool() async {
    if (!_isInit) {
      if (!_isInitializing) {
        await init();
        if (!_isInit) {
          throw Exception("The assistant tool is not initialized.");
        }
      } else {
        throw Exception("The assistant tool is initializing.");
      }
    }

    if (thread == null) {
      throw Exception("Thread is not initialized.");
    }

    if (assistant == null) {
      throw Exception("Assistant is not initialized.");
    }
  }

  Future<Assistant?> _getAssistant() async {
    if (_assistantId != null && !_assistantId!.isEmpty) {
      try {
        OpenAILogger.tryingToRetrieveObject("assistant");
        assistant = await OpenAI.instance.assistant.retrieve(_assistantId!);
      } catch (e) {
        print("Error retrieving assistant: $e");
      }
      if (assistant != null) return assistant;
      OpenAILogger.failedToRetrieveObject("assistant");
      await Future.delayed(Duration(milliseconds: INITIAL_DELAY_MILLIS));
    }

    OpenAILogger.creatingNewObject("assistant");

    return await _createAssistant();
  }

  Future<Assistant?> _createAssistant() async {
    StringBuffer sb = StringBuffer();
    sb.write(assistantOptions.instructions);
    sb.write(" Limit your response to $maxRequestLength characters.");

    try {
      return OpenAI.instance.assistant.create(
        model,
        name: assistantOptions.name,
        description: assistantOptions.description,
        instructions: sb.toString(),
        tools: assistantOptions.tools,
        toolResources: assistantOptions.toolResources,
        temperature: assistantOptions.temperature,
        topP: assistantOptions.topP,
        responseFormat: assistantOptions.responseFormat,
      );
    } catch (e) {
      print("Error creating assistant: $e");
    }

    return null;
  }

  /// Wait for the run status to change
  Future<Run?> _waitForRunStatusChange(RunStatus statusToWaitFor) async {
    DateTime endTime = DateTime.now().add(Duration(seconds: operationTimeoutSec));
    await Future.delayed(Duration(seconds: initialDelayForStateCheckSec));

    while (DateTime.now().isBefore(endTime)) {
      // Simulating retrieving the run status
      // Assume you have a method to check the status of the run
      if (thread != null && currentRun != null) {
        currentRun = await OpenAI.instance.run.retrieve(thread!.id, currentRun!.id) ?? currentRun;
      }

      RunStatus currentRunStatus = currentRun!.status ?? RunStatus.unknown;
      if (currentRun != null &&
          (currentRunStatus == statusToWaitFor ||
              currentRunStatus == RunStatus.completed ||
              currentRunStatus == RunStatus.expired ||
              currentRunStatus == RunStatus.cancelling ||
              currentRunStatus == RunStatus.cancelled ||
              currentRunStatus == RunStatus.failed)) {
        return currentRun;
      }

      await Future.delayed(Duration(seconds: recurringStateCheckIntervalSec));
    }

    print("Operation timed out after $operationTimeoutSec seconds.");

    return null;
  }

  // Legacy Codes (Assistant v1)
  // List<TResult>? _retrieveResult() {
  //   List<ToolCall>? resultToolCalls = currentRun?.requiredAction?.submitToolOutputs?.toolCalls;

  //   if (resultToolCalls == null) {
  //     print("No tool calls found in the run result.");

  //     return null;
  //   }

  //   List<String?> funcArgs = resultToolCalls
  //       .where((toolCall) => toolCall.function?.arguments != null)
  //       .map((toolCall) => toolCall.function!.arguments!)
  //       .toList();

  //   return funcArgs.map((arg) => createResponse(_parseResult(arg))).toList();
  // }

  // New Codes (Assistant v2)
  Future<List<TResult>?> _retrieveResult() async {
    var messageQuery =
        await OpenAI.instance.message.list(thread!.id, limit: 1, order: QueryOrder.descending);

    if (messageQuery.data == null || messageQuery.data!.isEmpty) {
      print("No message found in the thread.");

      return null;
    }

    var resultMessage = messageQuery.data!.first;

    if (resultMessage.role != ChatRole.assistant) {
      print("The latest message is not from the assistant.");

      return null;
    }

    var contentList = resultMessage.content;
    if (contentList == null || contentList.isEmpty) {
      print("No content found in the message.");

      return null;
    }

    List<String> jsonList = [];

    for (var content in contentList) {
      if (content.text == null || content.text!.value == null) continue;

      jsonList.add(content.text!.value!);
    }

    List<TResult> finalResult = [];

    for (var json in jsonList) {
      finalResult.add(createResponse(_decodeResultToMap(json)));
    }

    return finalResult;
  }

  Map<String, dynamic>? _decodeResultToMap(String? runResultJson) {
    if (runResultJson == null) return null;

    return jsonDecode(runResultJson);
  }

  Future<void> _completeRun(Run run) async {
    // Assuming you have a method to complete the run
    try {
      List<ToolOutput>? toolOutputs = currentRun?.requiredAction?.submitToolOutputs?.toolCalls
          ?.where((toolCall) => toolCall.id != null && toolCall.function?.arguments != null)
          .map((toolCall) =>
              ToolOutput(toolCallId: toolCall.id!, output: toolCall.function!.arguments!))
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
