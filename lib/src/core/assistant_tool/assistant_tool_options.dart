import 'package:flutter_openai/src/core/client/gpt_model.dart';

class AssistantToolOptions {
  String? assistantName;
  String? functionName;
  String? description;
  String? instruction;
  int maxCharacters = -1;
  bool stream = false;
  GPTModel? model;
  Function? onTokensValidated;
  Function? onTokensConsumed;
  Function? onError;

  bool get isValid {
    return assistantName?.isNotEmpty == true &&
        functionName?.isNotEmpty == true &&
        description?.isNotEmpty == true &&
        instruction?.isNotEmpty == true &&
        (maxCharacters >= 0 || maxCharacters == -1);
  }
}
