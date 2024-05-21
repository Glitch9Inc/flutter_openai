import 'package:flutter_openai/src/models/tool/code_interpreter/code_interpreter_resources.dart';
import 'package:flutter_openai/src/models/tool/file_search/file_search_resources.dart';

///A set of resources that are used by the assistant's tools.
///The resources are specific to the type of tool.
///For example, the code_interpreter tool requires a list of file IDs,
///while the file_search tool requires a list of vector store IDs.
abstract class ToolResource {
  const ToolResource();
  factory ToolResource.fromMap(Map<String, dynamic> map) {
    if (map['type'] == 'file_search') return FileSearchResources.fromMap(map);
    if (map['type'] == 'code_interpreter') return CodeInterpreterResources.fromMap(map);
    throw Exception('Invalid tool type');
  }

  Map<String, dynamic> toMap();
}
