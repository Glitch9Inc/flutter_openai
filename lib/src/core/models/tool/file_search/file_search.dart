import 'package:flutter_openai/flutter_openai.dart';

class FileSearch extends ToolBase {
  final String type;
  FileSearch({required this.type});
  factory FileSearch.fromMap(Map<String, dynamic> map) {
    return FileSearch(type: map['type']);
  }
  @override
  Map<String, dynamic> toMap() {
    return {'type': type};
  }
}
