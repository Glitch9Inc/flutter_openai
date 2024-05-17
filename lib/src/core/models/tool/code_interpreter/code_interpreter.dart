import 'package:flutter_openai/flutter_openai.dart';

class CodeInterpreter extends ToolBase {
  final String type;
  CodeInterpreter({required this.type});
  factory CodeInterpreter.fromMap(Map<String, dynamic> map) {
    return CodeInterpreter(type: map['type']);
  }
  @override
  Map<String, dynamic> toMap() {
    return {'type': type};
  }
}
