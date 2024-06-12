import 'package:flutter_openai/flutter_openai.dart';

class RunRequest {
  final GPTModel? model;
  final String? instructions;
  final String? additionalInstructions;
  final List<Message>? additionalMessages;
  final List<ToolCall>? tools;
  final Map<String, String>? metadata;
  final bool? stream;
  final double? temperature;
  final double? maxPromptTokens;
  final double? maxCompletionTokens;
  final double? topP;
  final ToolChoice? toolChoice;
  final ResponseFormat? responseFormat;

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
