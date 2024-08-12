import 'package:flutter_openai/src/model_tool/code_interpreter/code_interpreter_resources.dart';
import 'package:flutter_openai/src/model_tool/file_search/file_search_resources.dart';

///A set of resources that are used by the assistant's tools.
///The resources are specific to the type of tool.
///For example, the code_interpreter tool requires a list of file IDs,
///while the file_search tool requires a list of vector store IDs.
abstract class ToolResources {
  const ToolResources();
  factory ToolResources.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> codeInterpreter = map['code_interpreter'];
    if (codeInterpreter.isNotEmpty)
      return CodeInterpreterResources.fromMap(codeInterpreter);
    Map<String, dynamic> fileSearch = map['file_search'];
    if (fileSearch.isNotEmpty) return FileSearchResources.fromMap(fileSearch);
    throw Exception('Invalid tool type');
  }

  Map<String, dynamic> toMap();
}
