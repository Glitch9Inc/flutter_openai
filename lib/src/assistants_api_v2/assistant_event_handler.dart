import 'dart:async';

import 'package:flutter_openai/flutter_openai.dart';

class AssistantEventHandler {
  final StreamController<Assistant> _assistantGetController =
      StreamController<Assistant>.broadcast();
  final StreamController<Thread> _threadGetController = StreamController<Thread>.broadcast();

  final StreamController<void> _textCreatedController = StreamController<void>.broadcast();
  final StreamController<String> _textDeltaController = StreamController<String>.broadcast();

  final StreamController<ToolCall> _toolCallCreatedController =
      StreamController<ToolCall>.broadcast();
  final StreamController<ToolCall> _toolCallDeltaController =
      StreamController<ToolCall>.broadcast();

  final StreamController<Run> _runGetController = StreamController<Run>.broadcast();
  final StreamController<RunStep> _runStepGetController = StreamController<RunStep>.broadcast();
  final StreamController<Message> _messageCreatedController = StreamController<Message>.broadcast();
  final StreamController<Message> _messageCompletedController =
      StreamController<Message>.broadcast();

  final StreamController<RunStatus> _runStatusChangedController =
      StreamController<RunStatus>.broadcast();

  final StreamController<void> _streamDoneController = StreamController<void>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  // Exposing the streams
  Stream<Assistant> get onAssistantGet => _assistantGetController.stream;
  Stream<Thread> get onThreadGet => _threadGetController.stream;
  Stream<void> get onTextCreated => _textCreatedController.stream;
  Stream<String> get onTextDelta => _textDeltaController.stream;
  Stream<ToolCall> get onToolCallCreated => _toolCallCreatedController.stream;
  Stream<ToolCall> get onToolCallDelta => _toolCallDeltaController.stream;
  Stream<Run> get onRunGet => _runGetController.stream;
  Stream<RunStep> get onRunStepGet => _runStepGetController.stream;
  Stream<Message> get onMessageCreated => _messageCreatedController.stream;
  Stream<Message> get onMessageCompleted => _messageCompletedController.stream;
  Stream<RunStatus> get onRunStatusChanged => _runStatusChangedController.stream;
  Stream<void> get onStreamDone => _streamDoneController.stream;
  Stream<String> get onError => _errorController.stream;

  // Methods to trigger the events
  void triggerAssistantGet(Assistant assistant) {
    _assistantGetController.add(assistant);
  }

  void triggerThreadGet(Thread thread) {
    _threadGetController.add(thread);
  }

  void triggerTextCreated() {
    _textCreatedController.add(null);
  }

  void triggerTextDelta(String delta) {
    _textDeltaController.add(delta);
  }

  void triggerToolCallCreated(ToolCall toolCall) {
    _toolCallCreatedController.add(toolCall);
  }

  void triggerToolCallDelta(ToolCall toolCall) {
    _toolCallDeltaController.add(toolCall);
  }

  void triggerRunGet(Run run) {
    _runGetController.add(run);
  }

  void triggerRunStepGet(RunStep runStep) {
    _runStepGetController.add(runStep);
  }

  void triggerMessageCreated(Message message) {
    _messageCreatedController.add(message);
  }

  void triggerMessageCompleted(Message message) {
    _messageCompletedController.add(message);
  }

  void triggerRunStatusChanged(RunStatus runStatus) {
    _runStatusChangedController.add(runStatus);
  }

  void triggerStreamDone() {
    _streamDoneController.add(null);
  }

  void triggerError(String error) {
    _errorController.add(error);
  }

  // Dispose controllers when they are no longer needed to prevent memory leaks
  void dispose() {
    _assistantGetController.close();
    _threadGetController.close();
    _textCreatedController.close();
    _textDeltaController.close();
    _toolCallCreatedController.close();
    _toolCallDeltaController.close();
    _runGetController.close();
    _runStepGetController.close();
    _messageCreatedController.close();
    _messageCompletedController.close();
    _runStatusChangedController.close();
    _streamDoneController.close();
    _errorController.close();
  }
}
