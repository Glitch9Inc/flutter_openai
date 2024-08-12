import 'package:flutter_openai/flutter_openai.dart';

class CodeInterpreterResources extends ToolResources {
  final List<String>? fileIds;
  CodeInterpreterResources({this.fileIds});
  factory CodeInterpreterResources.fromMap(Map<String, dynamic> map) {
    return CodeInterpreterResources(
        fileIds: MapSetter.setList<String>(map, 'file_ids',
            factory: (item) => item as String));
  }
  @override
  Map<String, dynamic> toMap() {
    return {'file_ids': fileIds};
  }
}
