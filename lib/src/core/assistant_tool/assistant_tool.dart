import 'dart:async';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/assistant_tool/assistant_tool_options.dart';
import 'package:flutter_openai/src/core/assistant_tool/openai_object_base.dart';
import 'package:flutter_openai/src/core/assistant_tool/run_options.dart';
import 'package:flutter_openai/src/core/client/gpt_model.dart';

import '../sub_models/export.dart';

class AssistantTool<TToolResponse> {
  static const int DELAY_MILLIS = 1000;

  GPTModel? model;
  int minTokens = -1;
  AssistantToolOptions? toolOptions;
  RunOptions? runOptions;
  AssistantModel? assistant;
  OpenAIObjectBase? thread;
  DateTime? _lastRequestTime;
  String? _toolName;
  String? _threadId;
  String? _assistantId;

  AssistantTool(this.toolOptions, {RunOptions? runOptions}) {
    if (toolOptions == null || !toolOptions!.isValid) {
      throw ArgumentError("Missing required tool options or invalid options");
    }
    _toolName = runtimeType.toString();
    this.runOptions = runOptions ?? RunOptions.defaultOptions;
    client = this.runOptions?.client ?? OpenAiClient.defaultInstance;

    model = toolOptions!.model;
    minTokens = this.runOptions!.minTokenCountForRequests;

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

    bool toolsEmpty = assistant!.tools == null || assistant!.tools!.isEmpty;
    if (toolsEmpty && !(assistant!.tools![0] is FunctionToolCall)) {
      throw Exception("Initialization failed");
    }

    await onInitializeAsync();
  }

  Future<void> onInitializeAsync() async {
    // Override this method if needed
  }

  Future<OpenAIObjectBase?> _getThreadAsync() async {
    if (_threadId != null) {
      OpenAIObjectBase? thread = await client!.retrieveThread(_threadId!);
      if (thread != null) return thread;
      await Future.delayed(Duration(milliseconds: DELAY_MILLIS));
    }
    return await client!.createThread();
  }

  Future<AssistantModel?> _getAssistantAsync() async {
    AssistantModel? assistant;
    if (_assistantId != null) {
      assistant = await client!.retrieveAssistant(_assistantId!);
      if (assistant != null) return assistant;
      await Future.delayed(Duration(milliseconds: DELAY_MILLIS));
    }
    return await _createAssistantAsync();
  }

  Future<AssistantModel?> _createAssistantAsync() async {
    StringBuffer sb = StringBuffer();
    sb.write(toolOptions!.instruction);
    if (toolOptions!.maxCharacters != -1)
      sb.write(" Limit your response to ${toolOptions!.maxCharacters} characters.");

    FunctionModel function = _createFunction();

    AssistantRequest req = AssistantRequest.builder()
        .setName(toolOptions!.assistantName)
        .setModel(model)
        .setInstructions(sb.toString())
        .setFunctions(function)
        .build();

    return await OpenAiClient.defaultInstance.createAssistant(req);
  }

  FunctionModel _createFunction() {
    FunctionModel func = FunctionModel(toolOptions!.functionName);
    func.description = toolOptions!.description;
    FuncParams parameters = ToolUtils.createFuncParams<TToolResponse>();
    func.parameters = parameters;
    return func;
  }
}
