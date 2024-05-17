import 'package:flutter_openai/flutter_openai.dart';

class CodeInterpreter extends ToolResources {
  final List<String>? fileIds;
  CodeInterpreter({this.fileIds});
  factory CodeInterpreter.fromMap(Map<String, dynamic> map) {
    return CodeInterpreter(fileIds: map['file_ids']);
  }
  @override
  Map<String, dynamic> toMap() {
    return {'file_ids': fileIds};
  }
}
