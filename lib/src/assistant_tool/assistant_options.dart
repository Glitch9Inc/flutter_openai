import 'package:flutter_openai/flutter_openai.dart';

class AssistantOptions {
  final GPTModel model;
  final String name;
  final String description;
  final String instruction;
  final List<ToolBase>? tools;
  final ToolResources? toolResources;
  final Map<String, String>? metadata;
  final double? temperature;
  final double? topP;
  final String? responseFormat;

  const AssistantOptions({
    required this.model,
    required this.name,
    required this.description,
    required this.instruction,
    this.tools,
    this.toolResources,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });
}
