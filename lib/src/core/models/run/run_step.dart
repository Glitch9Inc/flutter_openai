import 'package:collection/collection.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/convert_utils.dart';

import 'run_error.dart';
import 'step_details.dart';

class RunStep {
  /// The identifier of the run step, which can be referenced in API endpoints.
  final String id;

  /// The object type, which is always thread.run.step.
  final String object;

  /// The Unix timestamp (in seconds) for when the run step was created.
  final DateTime createdAt;

  /// The ID of the assistant associated with the run step.
  final String assistantId;

  /// The ID of the thread that was run.
  final String threadId;

  /// The ID of the run that this run step is a part of.
  final String runId;

  /// The type of run step, which can be either message_creation or tool_calls.
  final String type;

  /// The status of the run step, which can be either in_progress, cancelled, failed, completed, or expired.
  final RunStatus status;

  /// The details of the run step.
  final StepDetails stepDetails;

  /// The last error associated with this run step. Will be null if there are no errors.
  final RunError? lastError;

  /// The Unix timestamp (in seconds) for when the run step expired. A step is considered expired if the parent run is expired.
  final DateTime? expiredAt;

  /// The Unix timestamp (in seconds) for when the run step was cancelled.
  final DateTime? cancelledAt;

  /// The Unix timestamp (in seconds) for when the run step failed.
  final DateTime? failedAt;

  /// The Unix timestamp (in seconds) for when the run step completed.
  final DateTime? completedAt;

  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format.
  final Map<String, dynamic> metadata;

  /// Usage statistics related to the run step. This value will be null while the run step's status is in_progress.
  final Usage? usage;

  @override
  int get hashCode =>
      id.hashCode ^
      object.hashCode ^
      createdAt.hashCode ^
      assistantId.hashCode ^
      threadId.hashCode ^
      runId.hashCode ^
      type.hashCode ^
      status.hashCode ^
      stepDetails.hashCode ^
      lastError.hashCode ^
      expiredAt.hashCode ^
      cancelledAt.hashCode ^
      failedAt.hashCode ^
      completedAt.hashCode ^
      metadata.hashCode ^
      usage.hashCode;

  RunStep({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.assistantId,
    required this.threadId,
    required this.runId,
    required this.type,
    required this.status,
    required this.stepDetails,
    this.lastError,
    this.expiredAt,
    this.cancelledAt,
    this.failedAt,
    this.completedAt,
    required this.metadata,
    this.usage,
  });

  /// Factory method to create a [RunStep] object from a [Map<String, dynamic>].
  factory RunStep.fromMap(Map<String, dynamic> map) {
    return RunStep(
      id: map['id'],
      object: map['object'],
      createdAt: ConvertUtils.fromUnix(map['created_at']),
      assistantId: map['assistant_id'],
      threadId: map['thread_id'],
      runId: map['run_id'],
      type: map['type'],
      status: ConvertUtils.fromString(map['status']),
      stepDetails: StepDetails.fromMap(map['step_details']),
      lastError: RunError.fromMap(map['last_error']),
      expiredAt: ConvertUtils.fromUnix(map['expired_at']),
      cancelledAt: ConvertUtils.fromUnix(map['cancelled_at']),
      failedAt: ConvertUtils.fromUnix(map['failed_at']),
      completedAt: ConvertUtils.fromUnix(map['completed_at']),
      metadata: Map<String, dynamic>.from(map['metadata']),
      usage: Usage.fromMap(Map<String, dynamic>.from(map['usage'])),
    );
  }

  /// Method to convert the [RunStep] object to a [Map<String, dynamic>].
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'object': object,
  //     'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
  //     'assistant_id': assistantId,
  //     'thread_id': threadId,
  //     'run_id': runId,
  //     'type': type,
  //     'status': status,
  //     'step_details': stepDetails,
  //     'last_error': lastError,
  //     'expired_at': expiredAt?.millisecondsSinceEpoch ~/ 1000,
  //     'cancelled_at': cancelledAt?.millisecondsSinceEpoch ~/ 1000,
  //     'failed_at': failedAt?.millisecondsSinceEpoch ~/ 1000,
  //     'completed_at': completedAt?.millisecondsSinceEpoch ~/ 1000,
  //     'metadata': metadata,
  //     'usage': usage?.toMap(),
  //   };
  // }

  @override
  String toString() {
    return 'RunStep(id: $id, object: $object, createdAt: $createdAt, assistantId: $assistantId, threadId: $threadId, runId: $runId, type: $type, status: $status, stepDetails: $stepDetails, lastError: $lastError, expiredAt: $expiredAt, cancelledAt: $cancelledAt, failedAt: $failedAt, completedAt: $completedAt, metadata: $metadata, usage: $usage)';
  }

  @override
  bool operator ==(covariant RunStep other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.object == object &&
        other.createdAt == createdAt &&
        other.assistantId == assistantId &&
        other.threadId == threadId &&
        other.runId == runId &&
        other.type == type &&
        other.status == status &&
        mapEquals(other.stepDetails, stepDetails) &&
        mapEquals(other.lastError, lastError) &&
        other.expiredAt == expiredAt &&
        other.cancelledAt == cancelledAt &&
        other.failedAt == failedAt &&
        other.completedAt == completedAt &&
        mapEquals(other.metadata, metadata) &&
        other.usage == usage;
  }
}
