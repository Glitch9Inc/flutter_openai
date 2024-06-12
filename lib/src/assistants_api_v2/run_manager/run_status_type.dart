import 'package:flutter_openai/flutter_openai.dart';

enum RunStatusType {
  success,
  failure,
  terminal,
}

extension RunStatusExtensions on RunStatusType {
  List<RunStatus> getStatusArray() {
    switch (this) {
      case RunStatusType.success:
        return [
          RunStatus.completed,
          RunStatus.requires_action,
        ];
      case RunStatusType.failure:
        return [
          RunStatus.expired,
          RunStatus.cancelling,
          RunStatus.cancelled,
          RunStatus.failed,
        ];
      case RunStatusType.terminal:
        return [
          RunStatus.completed,
          RunStatus.incomplete,
          RunStatus.expired,
          RunStatus.cancelled,
          RunStatus.failed,
        ];
    }
  }
}

extension RunStatusCheck on RunStatus? {
  bool isStatusType(RunStatusType type) {
    if (this == null) return false;

    return type.getStatusArray().contains(this);
  }
}

extension NonNullableRunStatusCheck on RunStatus {
  bool isStatusTypeNonNullable(RunStatusType type) {
    return type.getStatusArray().contains(this);
  }
}
