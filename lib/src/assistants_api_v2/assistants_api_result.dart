import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/required_actions/required_action_stack.dart';

enum AssistantsAPIResultStatus {
  Unknown,
  ReturnedResponse,
  Failed,
  RequiresAction,
}

class AssistantsApiResult extends Result {
  final Usage? usage;
  final String? stringResult;
  final List<String>? arrayResult;
  AssistantsAPIResultStatus status = AssistantsAPIResultStatus.Unknown;
  Map<String, RequiredActionStack> requiredActions = new Map<String, RequiredActionStack>();

  AssistantsApiResult._(
    bool isSuccess,
    String message,
    String failReason,
    this.usage,
    this.stringResult,
    this.arrayResult,
  ) : super.protected(isSuccess, message, failReason);

  factory AssistantsApiResult.success() {
    return AssistantsApiResult._(
      true,
      'Success',
      '',
      null,
      null,
      null,
    );
  }

  factory AssistantsApiResult.message(
    Message message, {
    Usage? usage,
  }) {
    // TODO : Implement this
    return AssistantsApiResult._(
      true,
      'Success',
      '',
      usage,
      null,
      null,
    );
  }

  factory AssistantsApiResult.fail(
    String failReason, {
    Usage? usage,
  }) {
    return AssistantsApiResult._(
      false,
      'Failed',
      failReason,
      usage,
      null,
      null,
    );
  }

  factory AssistantsApiResult.requiresAction(Map<String, RequiredActionStack> requiredActions) {
    return AssistantsApiResult._(
      false,
      'Requires Action',
      'Requires Action',
      null,
      null,
      null,
    );
  }
}
