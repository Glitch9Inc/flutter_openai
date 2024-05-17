import 'package:flutter_openai/flutter_openai.dart';

abstract class FunctionResponse {
  FunctionObject createFunctionWithParameters();
}
