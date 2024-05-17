import 'dart:async';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/assistant_tool/assistant_tool_options.dart';
import 'package:flutter_openai/src/core/assistant_tool/run_options.dart';
import 'package:flutter_openai/src/core/utils/logger.dart';

abstract class AssistantTool<TToolResponse> {
  static const int DELAY_MILLIS = 1000;

  GPTModel model = GPTModel.GPT4o;
  int minTokens = -1;
  AssistantToolOptions? toolOptions;
  RunOptions? runOptions;
  Assistant? assistant;
  Thread? thread;
  String? _toolName;
  String? _threadId;
  String? _assistantId;
  DateTime _lastRequestTime = DateTime.now();

  AssistantTool(this.toolOptions, {RunOptions? runOptions}) {
    if (toolOptions == null || !toolOptions!.isValid) {
      throw ArgumentError("Missing required tool options or invalid options");
    }
    _toolName = runtimeType.toString();
    this.runOptions = runOptions ?? RunOptions.defaultOptions;

    var defaultModel = toolOptions?.model;
    if (defaultModel != null) {
      model = defaultModel;
    }
    minTokens = this.runOptions?.minTokenCountForRequests ?? -1;

    _threadId = "$_toolName.ThreadId";
    _assistantId = "$_toolName.AssistantId";
  }

  Future<void> initializeAsync() async {
    thread = await _getThreadAsync();

    await Future.delayed(const Duration(milliseconds: DELAY_MILLIS));

    assistant = await _getAssistantAsync();

    if (assistant == null || thread == null) {
      throw Exception("Initialization failed");
    }

    _assistantId = assistant!.id;
    _threadId = thread!.id;

    bool toolsEmpty = assistant?.tools?.isEmpty ?? true;
    if (toolsEmpty) {
      throw Exception("Initialization failed. Tools are empty");
    }

    await onInitializeAsync();
  }

  Future<void> onInitializeAsync();

  Future<TToolResponse?> requestAsync(
    String textInput, {
    Function(String)? onRequestPrepared,
  }) async {
    if (textInput.isEmpty) {
      print("[$_toolName|Request] The input text is empty.");

      return null;
    }

    print("[$_toolName|Request] Requesting with input: $textInput");

    // Validate tokens (Assuming method exists)
    if (!_validateTokens(minTokens)) return null;

    // Check if request is too soon
    if (DateTime.now().difference(_lastRequestTime) < Duration(seconds: 2)) {
      print("[$_toolName|Request] The request is too fast. Please wait for a while.");
      return null;
    }

    _lastRequestTime = DateTime.now();
    textInput = _removeLineBreaks(textInput);

    Message messageRes = await OpenAI.instance.message.createWithText(
      thread!.id,
      role: ChatRole.user,
      content: textInput,
    );

    onRequestPrepared?.call(textInput);

    Run? runRes = await OpenAI.instance.run
        .create(thread!.id, assistantId: assistant!.id, function: _createFunction());

    if (runRes == null) {
      OpenAILogger.errorCreatingObject("run");

      return null;
    }

    runRes = await _waitForRunStatusChangeAsync(runRes, RunStatus.requires_action);
    if (runRes == null) return null;

    TToolResponse functionResult = _retrieveRunResult(runRes);
    if (functionResult == null) return null;

    _completeRun(runRes); // Handle usage and complete the run if necessary

    return functionResult;
  }

  Future<Thread?> _getThreadAsync() async {
    if (_threadId != null) {
      Thread? thread = await OpenAI.instance.thread.retrieve(_threadId!);
      if (thread != null) return thread;
      await Future.delayed(Duration(milliseconds: DELAY_MILLIS));
    }

    return await OpenAI.instance.thread.create();
  }

  Future<Assistant?> _getAssistantAsync() async {
    Assistant? assistant;
    if (_assistantId != null) {
      assistant = await OpenAI.instance.assistant.retrieve(_assistantId!);
      if (assistant != null) return assistant;
      await Future.delayed(Duration(milliseconds: DELAY_MILLIS));
    }

    return await _createAssistantAsync();
  }

  Future<Assistant?> _createAssistantAsync() async {
    StringBuffer sb = StringBuffer();
    sb.write(toolOptions!.instruction);
    if (toolOptions!.maxCharacters != -1)
      sb.write(" Limit your response to ${toolOptions!.maxCharacters} characters.");

    FunctionObject function = _createFunction();

    return await OpenAI.instance.assistant.create(
      model,
      name: toolOptions?.assistantName,
      instruction: sb.toString(),
      toolResources: function,
    );
  }

  FunctionObject _createFunction();
  TToolResponse _createResponse(Map<String, dynamic> runResult);
  bool _validateTokens(int minTokens);

  String _removeLineBreaks(String text) => text.replaceAll(RegExp(r'\n|\r'), '');

  Future<Run?> _waitForRunStatusChangeAsync(Run run, RunStatus statusToWaitFor) async {
    const int initialDelayMillis = 5000; // Initial delay before checking the run status
    const int delayMillis = 2000; // Delay between subsequent checks
    const int timeoutSec = 60; // Timeout in seconds

    DateTime endTime = DateTime.now().add(Duration(seconds: timeoutSec));
    await Future.delayed(Duration(milliseconds: initialDelayMillis));

    while (DateTime.now().isBefore(endTime)) {
      // Simulating retrieving the run status
      // Assume you have a method to check the status of the run
      run = await OpenAI.instance.run.retrieve(thread!.id, run.id) ?? run;

      if (run != null && run.status == statusToWaitFor) {
        return run;
      }

      await Future.delayed(Duration(milliseconds: delayMillis));
    }

    print("Operation timed out after $timeoutSec seconds.");
    return null;
  }

  TToolResponse _retrieveRunResult(Run run) {
    // Assuming the Run contains a field for the function result or similar
    if (run.result == null || run.result.isEmpty) {
      print("Failed to get function arguments from Run.");
      return null;
    }

    try {
      return _createResponse(run.result);
    } catch (e) {
      print("Error deserializing the response: $e");
      return null;
    }
  }

  Future<void> _completeRun(Run run) async {
    // Assuming you have a method to complete the run
    try {
      await _client.completeRun(run.id); // Implement this method as per your API
      print("Run completed successfully.");
    } catch (e) {
      print("Failed to complete the run: $e");
    }
  }
}
