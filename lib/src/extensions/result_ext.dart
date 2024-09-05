import 'package:flutter_openai/flutter_openai.dart';

extension ChatCompletionExt on ChatCompletion {
  String get textResult {
    return choices.first.message.content?.first.text?.value ?? '';
  }
}
