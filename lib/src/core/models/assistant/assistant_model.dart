import 'package:flutter_openai/src/core/assistant_tool/openai_object_base.dart';

import '../../sub_models/export.dart';

class AssistantModel extends OpenAIObjectBase {
  final String? name;
  final String? description;
  final String? instructions;
  final List<ToolCall>? tools;
  final List<String>? fileIds;

  const AssistantModel({
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.fileIds,
  });
}
