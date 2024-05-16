import 'package:flutter_openai/src/core/models/openai_object_base.dart';
import 'package:flutter_openai/src/core/sub_models/export.dart';

class AssistantObject extends OpenAIObjectBase {
  final String? name;
  final String? description;
  final String? instructions;
  final List<ToolCall>? tools;
  final List<String>? fileIds;

  const AssistantObject({
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.fileIds,
  });

  factory AssistantObject.fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
