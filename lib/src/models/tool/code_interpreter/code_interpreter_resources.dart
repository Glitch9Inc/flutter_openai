import 'package:flutter_openai/flutter_openai.dart';

class CodeInterpreterResources extends ToolResource {
  final List<String>? fileIds;
  CodeInterpreterResources({this.fileIds});
  factory CodeInterpreterResources.fromMap(Map<String, dynamic> map) {
    return CodeInterpreterResources(fileIds: map['file_ids']);
  }
  @override
  Map<String, dynamic> toMap() {
    return {'file_ids': fileIds};
  }
}
