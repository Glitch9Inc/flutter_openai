import 'package:flutter_openai/flutter_openai.dart';

class RunRequest {
  GPTModel? model;
  String? instructions;
  String? additionalInstructions;
  List<Message>? additionalMessages;
  List<ToolCall>? tools;
  Map<String, String>? metadata;
  bool? stream;
  double? temperature;
  double? maxPromptTokens;
  double? maxCompletionTokens;
  double? topP;
  ToolChoice? toolChoice;
  ResponseFormat? responseFormat;

  RunRequest({
    this.model,
    this.instructions,
    this.additionalInstructions,
    this.additionalMessages,
    this.tools,
    this.metadata,
    this.stream,
    this.temperature,
    this.maxPromptTokens,
    this.maxCompletionTokens,
    this.topP,
    this.toolChoice,
    this.responseFormat,
  });
}
