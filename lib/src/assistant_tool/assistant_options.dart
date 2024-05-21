import 'package:flutter_openai/flutter_openai.dart';

class AssistantOptions {
  final GPTModel model;
  final String name;
  final String description;
  final String instructions;
  final List<ToolCall>? tools;
  final ToolResource? toolResources;
  final Map<String, String>? metadata;
  final double? temperature;
  final double? topP;
  final ResponseFormat? responseFormat;

  const AssistantOptions({
    required this.model,
    required this.name,
    required this.description,
    required this.instructions,
    this.tools,
    this.toolResources,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });
}
