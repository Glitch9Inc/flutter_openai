import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/models/tool/code_interpreter/code_interpreter.dart';
import 'package:flutter_openai/src/core/models/tool/file_search/file_search.dart';

///A set of resources that are used by the assistant's tools.
///The resources are specific to the type of tool.
///For example, the code_interpreter tool requires a list of file IDs,
///while the file_search tool requires a list of vector store IDs.
abstract class ToolBase {
  const ToolBase();
  factory ToolBase.fromMap(Map<String, dynamic> map) {
    //if (map['type'] == 'function')
    if (map['type'] == 'file_search') return FileSearch.fromMap(map);
    if (map['type'] == 'code_interpreter') return CodeInterpreter.fromMap(map);

    return FunctionObject.fromMap(map);
  }

  Map<String, dynamic> toMap();
}
