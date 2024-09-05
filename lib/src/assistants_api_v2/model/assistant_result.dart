import 'dart:convert';

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/model/required_action_stack.dart';
import '../../flutter_openai_internal.dart';

enum AssistantsAPIResultStatus {
  Unknown,
  ReturnedResponse,
  Failed,
  RequiresAction,
}

class AssistantResult extends Result {
  final Usage? usage;
  final String? stringResult;
  final List<String>? arrayResult;
  AssistantsAPIResultStatus status = AssistantsAPIResultStatus.Unknown;
  Map<String, RequiredActionStack> requiredActions = new Map<String, RequiredActionStack>();

  AssistantResult._(
    bool success,
    String message,
    this.usage,
    this.stringResult,
    this.arrayResult,
  ) : super(success: success, message: message);

  factory AssistantResult.success() {
    return AssistantResult._(
      true,
      'Success',
      null,
      null,
      null,
    );
  }

  factory AssistantResult.message(
    Message message, {
    Usage? usage,
  }) {
    if (message.content == null) {
      return AssistantResult.error('Message content is null');
    }

    List<String> content = [];
    for (MessageContent item in message.content!) {
      if (item.text != null && item.text!.value != null) {
        content.add(item.text!.value!);
      }
    }

    return AssistantResult._(
      true,
      'Success',
      usage,
      null,
      content,
    );
  }

  factory AssistantResult.error(
    String? failReason, {
    Usage? usage,
  }) {
    return AssistantResult._(
      false,
      failReason ?? 'Failed',
      usage,
      null,
      null,
    );
  }

  factory AssistantResult.requiresAction(Map<String, RequiredActionStack> requiredActions) {
    return AssistantResult._(
      false,
      'Requires Action',
      null,
      null,
      null,
    );
  }
}

extension AssistantsApiResultExt on AssistantResult {
  String? getOutputText() {
    if (!stringResult.isNullOrEmpty) return stringResult;
    if (arrayResult != null && arrayResult!.isNotEmpty) return arrayResult!.first;
    return null;
  }

  T? getObject<T>({required T Function(Map<String, dynamic>) factory}) {
    if (!stringResult.isNullOrEmpty) {
      T? result = tryDecode(stringResult!, factory);
      if (result != null) return result;
    }

    if (arrayResult != null) {
      if (arrayResult!.isEmpty) return null;
      for (String jsonString in arrayResult!) {
        T? result = tryDecode(jsonString, factory);
        if (result != null) return result;
      }
    }

    return null;
  }

  T? tryDecode<T>(String jsonString, T Function(Map<String, dynamic>) factory) {
    try {
      var dynamicMap = jsonDecode(jsonString);
      if (dynamicMap is Map<String, dynamic>) {
        return factory(dynamicMap);
      }
    } catch (e) {
      OpenAI.logger.severe('Failed to decode JSON: $e');
    }
    return null;
  }
}
