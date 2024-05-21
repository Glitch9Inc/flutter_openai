import 'package:collection/collection.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/models/message/incomplete_details.dart';
import 'package:flutter_openai/src/models/run/truncation_strategy.dart';
import 'package:flutter_openai/src/models/tool/tool_choice.dart';

import 'required_action.dart';
import 'run_error.dart';

export 'run_status.dart';

class Run {
  /// The identifier, which can be referenced in API endpoints.
  final String id;

  /// The object type, which is always thread.run.
  final String? object;

  /// The Unix timestamp (in seconds) for when the run was created.
  final DateTime? createdAt;

  /// The ID of the thread that was executed on as a part of this run.
  final String? threadId;

  /// The ID of the assistant used for execution of this run.
  final String? assistantId;

  /// The status of the run, which can be either queued, in_progress, requires_action, cancelling, cancelled, failed, completed, incomplete, or expired.
  final RunStatus? status;

  /// Details on the action required to continue the run. Will be null if no action is required.
  final RequiredAction? requiredAction;

  /// The last error associated with this run. Will be null if there are no errors.
  final RunError? lastError;

  /// The Unix timestamp (in seconds) for when the run will expire.
  final DateTime? expiresAt;

  /// The Unix timestamp (in seconds) for when the run was started.
  final DateTime? startedAt;

  /// The Unix timestamp (in seconds) for when the run was cancelled.
  final DateTime? cancelledAt;

  /// The Unix timestamp (in seconds) for when the run failed.
  final DateTime? failedAt;

  /// The Unix timestamp (in seconds) for when the run was completed.
  final DateTime? completedAt;

  /// Details on why the run is incomplete. Will be null if the run is not incomplete.
  final IncompleteDetails? incompleteDetails;

  /// The model that the assistant used for this run.
  final GPTModel? model;

  /// The instructions that the assistant used for this run.
  final String? instructions;

  /// The list of tools that the assistant used for this run.
  final List<ToolCall>? tools;

  /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format.
  final Map<String, String>? metadata;

  /// Usage statistics related to the run. This value will be null if the run is not in a terminal state (i.e. in_progress, queued, etc.).
  final Usage? usage;

  /// The sampling temperature used for this run. If not set, defaults to 1.
  final double? temperature;

  /// The nucleus sampling value used for this run. If not set, defaults to 1.
  final double? topP;

  /// The maximum number of prompt tokens specified to have been used over the course of the run.
  final int? maxPromptTokens;

  /// The maximum number of completion tokens specified to have been used over the course of the run.
  final int? maxCompletionTokens;

  /// Controls for how a thread will be truncated prior to the run. Use this to control the initial context window of the run.
  final TruncationStrategy? truncationStrategy;

  /// Controls which (if any) tool is called by the model.
  /// - none: the model will not call any tools and instead generates a message.
  /// - auto: the model can pick between generating a message or calling one or more tools.
  /// - required: the model must call one or more tools before responding to the user.
  /// Specifying a particular tool like {"type": "file_search"} or {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool.
  final ToolChoice? toolChoice;

  /// Specifies the format that the model must output. Compatible with GPT-4o, GPT-4 Turbo, and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
  /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
  final ResponseFormat? responseFormat;

  Run({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.threadId,
    required this.assistantId,
    required this.status,
    required this.requiredAction,
    required this.lastError,
    required this.expiresAt,
    required this.startedAt,
    required this.cancelledAt,
    required this.failedAt,
    required this.completedAt,
    required this.incompleteDetails,
    required this.model,
    required this.instructions,
    required this.tools,
    required this.metadata,
    required this.usage,
    required this.temperature,
    required this.topP,
    required this.maxPromptTokens,
    required this.maxCompletionTokens,
    required this.truncationStrategy,
    required this.toolChoice,
    required this.responseFormat,
  });

  /// Factory method to create a [Run] object from a [Map<String, dynamic>].
  factory Run.fromMap(Map<String, dynamic> map) {
    return Run(
      id: MapSetter.set<String>(map, 'id')!,
      object: MapSetter.set<String>(map, 'object'),
      createdAt: MapSetter.set<DateTime>(map, 'created_at'),
      threadId: MapSetter.set<String>(map, 'thread_id'),
      assistantId: MapSetter.set<String>(map, 'assistant_id'),
      status: MapSetter.setEnum<RunStatus>(
        map,
        'status',
        enumValues: RunStatus.values,
        defaultValue: RunStatus.unknown,
      ),
      requiredAction: MapSetter.set<RequiredAction>(
        map,
        'required_action',
        factory: RequiredAction.fromMap,
      ),
      lastError: MapSetter.set<RunError>(
        map,
        'last_error',
        factory: RunError.fromMap,
      ),
      expiresAt: MapSetter.set<DateTime>(map, 'expires_at'),
      startedAt: MapSetter.set<DateTime>(map, 'started_at'),
      cancelledAt: MapSetter.set<DateTime>(map, 'cancelled_at'),
      failedAt: MapSetter.set<DateTime>(map, 'failed_at'),
      completedAt: MapSetter.set<DateTime>(map, 'completed_at'),
      incompleteDetails: MapSetter.set<IncompleteDetails>(
        map,
        'incomplete_details',
        factory: IncompleteDetails.fromMap,
      ),
      model: MapSetter.set<GPTModel>(map, 'model'),
      instructions: MapSetter.set<String>(map, 'instructions'),
      tools: MapSetter.setList<ToolCall>(map, 'tools', factory: ToolCall.fromMap),
      metadata: MapSetter.setMap<String>(map, 'metadata'),
      usage: MapSetter.set<Usage>(map, 'usage', factory: Usage.fromMap),
      temperature: MapSetter.set<double>(map, 'temperature'),
      topP: MapSetter.set<double>(map, 'top_p'),
      maxPromptTokens: MapSetter.set<int>(map, 'max_prompt_tokens'),
      maxCompletionTokens: MapSetter.set<int>(map, 'max_completion_tokens'),
      truncationStrategy: MapSetter.set<TruncationStrategy>(
        map,
        'truncation_strategy',
        factory: TruncationStrategy.fromMap,
      ),
      toolChoice: MapSetter.setStringOr<ToolChoice>(
        map,
        'tool_choice',
        stringFactory: ToolChoice.fromString,
        mapFactory: ToolChoice.fromMap,
      ),
      responseFormat: MapSetter.setStringOr<ResponseFormat>(
        map,
        'response_format',
        stringFactory: ResponseFormat.fromString,
        mapFactory: ResponseFormat.fromMap,
      ),
    );
  }

  /// Method to convert the [Run] object to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'object': object,
      'created_at': createdAt?.toIso8601String(),
      'thread_id': threadId,
      'assistant_id': assistantId,
      'status': status?.name,
      'required_action': requiredAction?.toMap(),
      'last_error': lastError?.toMap(),
      'expires_at': expiresAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'incomplete_details': incompleteDetails?.toMap(),
      'model': model?.name,
      'instructions': instructions,
      'tools': tools?.map((tool) => tool.toMap()).toList(),
      'metadata': metadata,
      'usage': usage?.toMap(),
      'temperature': temperature,
      'top_p': topP,
      'max_prompt_tokens': maxPromptTokens,
      'max_completion_tokens': maxCompletionTokens,
      'truncation_strategy': truncationStrategy?.toMap(),
      'tool_choice': toolChoice?.toStringOrMap(),
      'response_format': responseFormat?.toStringOrMap(),
    };
  }

  @override
  String toString() {
    return 'Run(id: $id, object: $object, createdAt: $createdAt, threadId: $threadId, assistantId: $assistantId, status: $status, requiredAction: $requiredAction, lastError: $lastError, expiresAt: $expiresAt, startedAt: $startedAt, cancelledAt: $cancelledAt, failedAt: $failedAt, completedAt: $completedAt, incompleteDetails: $incompleteDetails, model: $model, instructions: $instructions, tools: $tools, metadata: $metadata, usage: $usage, temperature: $temperature, topP: $topP, maxPromptTokens: $maxPromptTokens, maxCompletionTokens: $maxCompletionTokens, truncationStrategy: $truncationStrategy, toolChoice: $toolChoice, responseFormat: $responseFormat)';
  }

  @override
  bool operator ==(covariant Run other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.object == object &&
        other.createdAt == createdAt &&
        other.threadId == threadId &&
        other.assistantId == assistantId &&
        other.status == status &&
        mapEquals(other.requiredAction, requiredAction) &&
        mapEquals(other.lastError, lastError) &&
        other.expiresAt == expiresAt &&
        other.startedAt == startedAt &&
        other.cancelledAt == cancelledAt &&
        other.failedAt == failedAt &&
        other.completedAt == completedAt &&
        mapEquals(other.incompleteDetails, incompleteDetails) &&
        other.model == model &&
        other.instructions == instructions &&
        mapEquals(other.tools, tools) &&
        mapEquals(other.metadata, metadata) &&
        mapEquals(other.usage, usage) &&
        other.temperature == temperature &&
        other.topP == topP &&
        other.maxPromptTokens == maxPromptTokens &&
        other.maxCompletionTokens == maxCompletionTokens &&
        mapEquals(other.truncationStrategy, truncationStrategy) &&
        other.toolChoice == toolChoice &&
        other.responseFormat == responseFormat;
  }
}
