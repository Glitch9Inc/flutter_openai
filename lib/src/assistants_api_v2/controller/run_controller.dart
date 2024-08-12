import 'dart:async';
import 'dart:math';

import 'package:flutter_openai/src/flutter_openai_internal.dart';

import '../model/run_status_type.dart';
import '../client/assistants_api_v2_util.dart';

enum RunCheckType {
  ResponseCheck,
  TerminalCheck,
}

class RunController {
  static const int waitUntilDelay = 100;
  static const int delayMultiplier = 2;
  static const int maxDelayMillis = 30000;

  final RunLogger _runLogger = RunLogger();

  /// Gets or sets the initial delay for the run status check in seconds.
  final int initialDelayForRunStatusCheckSec;

  /// Gets or sets the recurring run status check interval in seconds.
  final int recurringRunStatusCheckIntervalSec;

  /// Gets or sets the timeout for the run operation in seconds.
  final int runOperationTimeoutSec;

  final AssistantsAPIv2 _api;
  RunStatus get currentRunStatus => _api.runStatus;

  RunController(this._api, AssistantOptions options)
      : initialDelayForRunStatusCheckSec = options.initialDelayForRunStatusCheckSec,
        recurringRunStatusCheckIntervalSec = options.recurringRunStatusCheckIntervalSec,
        runOperationTimeoutSec = options.runOperationTimeoutSec;

  Future<void> waitUntil(RunStatusType runStatusType) async {
    Future.doWhile(() {
      Future.delayed(Duration(milliseconds: waitUntilDelay));

      return !currentRunStatus.isStatusType(runStatusType, _runLogger);
    });
  }

  Future<void> createNonStreamResponse() async {
    if (_api.status == AssistantStatus.ProcessingRun) {
      Run? run = _api.run;
      if (run == null) return;

      if (run.status == RunStatus.completed) {
        await _retrieveLastAssistantMessage();
        return;
      }

      if (run.status == RunStatus.requires_action) {
        await _api.handleRequiredAction();
        return;
      }
    }

    AssistantsAPIv2Util.updateAPIStatus(_api, AssistantStatus.ProcessingRun);
    Run? run = await retrieveRunUntilConditionsAreMetAsync(
      _api.thread,
      _api.run,
      RunCheckType.ResponseCheck,
    );

    if (run == null) {
      await _api.cancelRun();
      throw Exception("Run object is null.");
    }

    if (run.status != RunStatus.completed && run.status != RunStatus.requires_action) {
      _api.logger.severe("Canceling run with id: ${run.id} because it is not completed or requires action.");
      await _api.cancelRun();
      throw Exception("Run operation failed with status: ${run.status}.");
    }

    _api.run = run;

    if (run.status == RunStatus.completed) {
      await _retrieveLastAssistantMessage();

      return;
    }

    if (run.status == RunStatus.requires_action) {
      await _api.handleRequiredAction();

      return;
    }

    String runStatusString = _api.run?.status.toString() ?? "null";

    throw Exception("Run operation failed to complete with status: ${runStatusString}.");
  }

  Future<Run?> retrieveRunUntilConditionsAreMetAsync(
    Thread? thread,
    Run? run,
    RunCheckType checkType,
  ) async {
    if (thread == null) {
      _runLogger.severe("Thread object is null.");
      return null;
    }

    if (run == null) {
      _runLogger.severe("Run object is null.");
      return null;
    }

    // int initialDelayMillis = initialDelayForRunStatusCheckSec * 1000;
    // int delayMillis = recurringRunStatusCheckIntervalSec * 1000;
    // int timeoutSec = runOperationTimeoutSec;
    // if (timeoutSec <= 30) timeoutSec = 30;
    int initialDelayMillis = 2000;
    int delayMillis = 2000;
    int timeoutSec = 60;
    String runId = run.id;

    Duration maxWaitTime = Duration(seconds: timeoutSec);
    DateTime runTimeout = DateTime.now().add(maxWaitTime);

    await Future.delayed(Duration(milliseconds: initialDelayMillis));

    while (DateTime.now().isBefore(runTimeout)) {
      run = await _api.runProvider.retrieve(runId);

      if (run != null) {
        if (run.status != null) {
          _api.onRunStatusChanged(run.status!);

          if (checkType == RunCheckType.ResponseCheck) {
            if (run.status.isStatusType(RunStatusType.success)) {
              return run;
            }

            if (run.status == RunStatus.incomplete) {
              _handleIncompleteRun(run);

              return run;
            }

            if (run.status!.isStatusType(RunStatusType.failure, _runLogger)) {
              _runLogger.severe("Operation failed with status: ${run.status}");

              return run;
            }
          } else if (checkType == RunCheckType.TerminalCheck) {
            if (run.status.isStatusType(RunStatusType.terminal)) {
              return run;
            }
          }
        }
      }

      await Future.delayed(Duration(milliseconds: delayMillis));
      delayMillis = min(delayMillis * delayMultiplier, maxDelayMillis);
    }

    _runLogger.severe("Operation timed out after $timeoutSec seconds.");

    return run;
  }

  void _handleIncompleteRun(Run currentRun) {
    String? incompleteReason = currentRun.incompleteDetails?.reason;
    if (incompleteReason == null) {
      _runLogger.severe("Run operation is incomplete but the reason is not provided.");

      return;
    }
    _runLogger.severe("Operation is incomplete: $incompleteReason");
  }

  Future<void> _retrieveLastAssistantMessage() async {
    AssistantsAPIv2Util.updateAPIStatus(_api, AssistantStatus.HandlingResponse);

    Query<Message> messages = await OpenAI.instance.message.list(_api.threadId, limit: 1);

    Message? lastMessage = messages.data?.first;
    if (lastMessage == null) throw Exception("The last message is null.");

    if (lastMessage.role != ChatRole.assistant) throw Exception("The last message is not from ChatRole.Assistant.");
    _api.onAssistantMessageCreated(lastMessage);
  }
}

extension on RunStatus {
  bool isStatusType(RunStatusType type, RunLogger runLogger) {
    runLogger.runStatus(this);
    switch (type) {
      case RunStatusType.success:
        return this == RunStatus.completed || this == RunStatus.requires_action;
      case RunStatusType.failure:
        return this == RunStatus.failed || this == RunStatus.cancelled || this == RunStatus.expired;
      case RunStatusType.terminal:
        return this == RunStatus.completed ||
            this == RunStatus.requires_action ||
            this == RunStatus.failed ||
            this == RunStatus.cancelled ||
            this == RunStatus.expired;
    }
  }
}
