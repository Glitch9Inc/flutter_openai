import 'dart:async';
import 'dart:math';

import 'package:flutter_openai/src/flutter_openai_internal.dart';

import 'run_status_type.dart';

enum RunCheckType {
  ResponseCheck,
  TerminalCheck,
}

class RunManager {
  static const int waitUntilDelay = 100;
  static const int delayMultiplier = 2;
  static const int maxDelayMillis = 30000;

  /// Gets or sets the initial delay for the run status check in seconds.
  final int initialDelayForRunStatusCheckSec;

  /// Gets or sets the recurring run status check interval in seconds.
  final int recurringRunStatusCheckIntervalSec;

  /// Gets or sets the timeout for the run operation in seconds.
  final int runOperationTimeoutSec;

  final AssistantsAPIv2 _api;
  RunStatus get currentRunStatus => _api.runStatus;

  RunManager(this._api, AssistantsApiOptions options)
      : initialDelayForRunStatusCheckSec = options.initialDelayForRunStatusCheckSec,
        recurringRunStatusCheckIntervalSec = options.recurringRunStatusCheckIntervalSec,
        runOperationTimeoutSec = options.runOperationTimeoutSec;

  Future<void> waitUntil(RunStatusType runStatusType) async {
    Future.doWhile(() {
      Future.delayed(Duration(milliseconds: waitUntilDelay));

      return !currentRunStatus.isStatusType(runStatusType);
    });
  }

  Future<void> createNonStreamResponse() async {
    if (_api.assistantStatus == AssistantStatus.ProcessingRun) {
      Run? run = _api.run;

      if (run == null) {
        await _api.cancelRun();
        throw Exception("Run object is null.");
      }

      if (run.status == RunStatus.completed) {
        await _retrieveLastAssistantMessage();

        return;
      }

      if (run.status == RunStatus.requires_action) {
        await _api.handleRequiredAction();

        return;
      }
    }

    _api.updateAPIStatus(AssistantStatus.ProcessingRun);
    Run? run = await retrieveRunUntilConditionsAreMetAsync(
      _api.thread!,
      _api.run!,
      RunCheckType.ResponseCheck,
    );

    if (run == null) {
      await _api.cancelRun();
      throw Exception("Run object is null.");
    }

    if (run.status != RunStatus.completed && run.status != RunStatus.requires_action) {
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

    throw Exception("Run operation failed to complete with status: ${_api.run!.status}.");
  }

  Future<Run?> retrieveRunUntilConditionsAreMetAsync(
    Thread? thread,
    Run? run,
    RunCheckType checkType,
  ) async {
    if (thread == null || run == null) return null;

    int initialDelayMillis = initialDelayForRunStatusCheckSec * 1000;
    int delayMillis = recurringRunStatusCheckIntervalSec * 1000;
    int timeoutSec = runOperationTimeoutSec;
    String runId = run.id;

    Duration maxWaitTime = Duration(seconds: timeoutSec);
    DateTime runTimeout = DateTime.now().add(maxWaitTime);

    await Future.delayed(Duration(milliseconds: initialDelayMillis));

    while (DateTime.now().isBefore(runTimeout)) {
      run = await _api.runProvider.retrieve(runId);

      if (_runAndRunStatusNotNull(run)) {
        _api.onRunStatusChanged(run!.status!);

        if (checkType == RunCheckType.ResponseCheck) {
          if (run.status!.isStatusType(RunStatusType.success)) {
            return run;
          }

          if (run.status == RunStatus.incomplete) {
            _handleIncompleteRun(run);

            return run;
          }

          if (run.status!.isStatusType(RunStatusType.failure)) {
            OpenAILogger.error("Operation failed with status: ${run.status}");

            return run;
          }
        } else if (checkType == RunCheckType.TerminalCheck) {
          if (run.status!.isStatusType(RunStatusType.terminal)) {
            return run;
          }
        }
      }

      await Future.delayed(Duration(milliseconds: delayMillis));
      delayMillis = min(delayMillis * delayMultiplier, maxDelayMillis);
    }

    OpenAILogger.error("Operation timed out after $timeoutSec seconds.");

    return run;
  }

  bool _runAndRunStatusNotNull(Run? run) {
    if (run == null) {
      OpenAILogger.log("Run object is null.");

      return false;
    }

    if (run.status != null) return true;

    OpenAILogger.log("Run status is null.");

    return false;
  }

  void _handleIncompleteRun(Run currentRun) {
    String? incompleteReason = currentRun.incompleteDetails?.reason;
    if (incompleteReason == null) {
      OpenAILogger.error("Run operation is incomplete but the reason is not provided.");

      return;
    }
    OpenAILogger.error("Operation is incomplete: $incompleteReason");
  }

  Future<void> _retrieveLastAssistantMessage() async {
    _api.updateAPIStatus(AssistantStatus.HandlingResponse);

    Query<Message> messages = await OpenAI.instance.message.list(_api.threadId, limit: 1);
    if (messages.data == null || messages.data!.isEmpty) throw Exception("No messages found.");

    Message lastMessage = messages.data!.first;
    if (lastMessage.role != ChatRole.assistant)
      throw Exception("The last message is not from ChatRole.Assistant.");
    _api.onAssistantMessageCreated(lastMessage);
  }
}

extension on RunStatus {
  bool isStatusType(RunStatusType type) {
    switch (type) {
      case RunStatusType.success:
        return this == RunStatus.completed;
      case RunStatusType.failure:
        return this == RunStatus.failed || this == RunStatus.cancelled || this == RunStatus.expired;
      case RunStatusType.terminal:
        return this == RunStatus.completed ||
            this == RunStatus.failed ||
            this == RunStatus.cancelled ||
            this == RunStatus.expired;
    }
  }
}
