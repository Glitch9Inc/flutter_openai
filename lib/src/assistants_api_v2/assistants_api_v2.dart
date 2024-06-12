import 'dart:async';
import 'dart:io';

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/assistant_event_handler.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/assistant_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/message_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/run_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/run_step_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/thread_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/requests/message_request.dart';
import 'package:flutter_openai/src/assistants_api_v2/run_manager/run_manager.dart';
import 'package:flutter_openai/src/assistants_api_v2/run_manager/run_status_type.dart';
import 'package:flutter_openai/src/utils/extensions.dart';
import 'package:flutter_openai/src/utils/openai_logger.dart';

import 'requests/transcription_request.dart';
import 'required_actions/required_action_stack.dart';

export 'package:flutter_openai/src/assistants_api_v2/assistants_api_options.dart';
export 'package:flutter_openai/src/assistants_api_v2/assistants_api_result.dart';
export 'package:flutter_openai/src/assistants_api_v2/requests/run_request.dart';

enum AssistantStatus {
  Initializing,
  WaitingForInput,
  ProcessingRun,
  RequiresAction,
  HandlingResponse,
}

class AssistantsAPIv2 {
  static const int MIN_INTERNAL_OPERATION_MILLIS = 1000;
  static const int MIN_INTERVAL_REQUEST_MILLIS = 2000;

  // Default values
  static const GPTModel DEFAULT_MODEL = GPTModel.GPT4o;
  static const int DEFAULT_MAX_REQUEST_LENGTH = 1000;
  static const int DEFAULT_MIN_TOKEN_REQUIREMENT = 500;
  static const int DEFAULT_INITIAL_DELAY_FOR_STATE_CHECK_SEC = 4;
  static const int DEFAULT_RECURRING_STATE_CHECK_INTERVAL_SEC = 2;
  static const int DEFAULT_OPERATION_TIMEOUT_SEC = 60;
  static const int DEFAULT_ASSISTANTS_FETCH_COUNT = 20;

  TokenValidator? tokenValidator;
  UsageHandler? usageHandler;
  ExceptionHandler? exceptionHandler;

  final Prefs<String> savedThreadId;
  final Prefs<String> savedAssistantId;
  final PrefsMap<String, Message> savedMessages;
  final RunRequest defaultRunRequest;
  final Logger logger;

  // Assistants API Options
  String? id;
  GPTModel model = DEFAULT_MODEL;
  String? name;
  String? description;
  String? instructions;
  List<ToolCall>? tools;
  ToolResources? toolResources;
  ToolChoice? forcedTool;
  ResponseFormat? responseFormat;
  Map<String, String>? metadata;
  double? temperature;
  double? topP;

  // Public Properties: Run Options

  int minTokenRequirementPerRequest = DEFAULT_MIN_TOKEN_REQUIREMENT;
  int maxRequestLength = DEFAULT_MAX_REQUEST_LENGTH;
  int assistantsFetchCount = DEFAULT_ASSISTANTS_FETCH_COUNT;
  double maxPromptTokens = -1;
  double maxCompletionTokens = 1;

  // Public Properties: Object Tracking
  Assistant? assistant;
  Thread? thread;
  Run? run;
  RunStep? runStep;
  RunRequest? lastRunRequest;
  MessageRequest? lastMessageRequest;

  Message? lastUserMessage;
  Message? lastAssistantMessage;
  Message? lastToolMessage;
  AssistantEventHandler? eventHandler;

  // Status Tracking
  RunStatus runStatus = RunStatus.unknown;
  AssistantStatus assistantStatus = AssistantStatus.Initializing;
  bool stream = false;

  // Providers & Managers
  AssistantProvider? _assistantProvider;
  ThreadProvider? _threadProvider;
  MessageProvider? _messageProvider;
  RunProvider? _runProvider;
  RunStepProvider? _runStepProvider;
  RunManager? _runManager;

  bool _logRunStatusChange = true;
  bool _saveThreadMessages = false;

  DateTime _lastRequestTime = DateTime.now();
  Map<String, RequiredActionStack> _requiredActions = new Map<String, RequiredActionStack>();
  bool _waitingForRequiredActionCompletions = false;
  bool _newAssistantMessageCreated = false;
  bool _isInit = false;

  AssistantProvider get assistantProvider => _assistantProvider!;
  ThreadProvider get threadProvider => _threadProvider!;
  MessageProvider get messageProvider => _messageProvider!;
  RunProvider get runProvider => _runProvider!;
  RunStepProvider get runStepProvider => _runStepProvider!;
  RunManager get runManager => _runManager!;

  String get assistantId => savedThreadId.value ?? '';
  String get threadId => savedThreadId.value ?? '';
  String get runId => run?.id ?? '';
  bool get requiresAction => runStatus == RunStatus.requires_action;

  AssistantsAPIv2._internal(
    AssistantsApiOptions options,
    this.savedThreadId,
    this.savedAssistantId,
    this.savedMessages,
    this.defaultRunRequest,
    this.logger,
  ) {
    // late initialization
    _assistantProvider = AssistantProvider(this, logger);
    _threadProvider = ThreadProvider(this, logger);
    _messageProvider = MessageProvider(this, logger);
    _runProvider = RunProvider(this, logger);
    _runStepProvider = RunStepProvider(this, logger);
    _runManager = RunManager(this, options);

    tokenValidator = options.tokenValidator;
    usageHandler = options.usageHandler;
    exceptionHandler = options.exceptionHandler;

    name = options.name;
    model = options.model;
    description = options.description;
    instructions = options.instructions;
    tools = options.tools;
    toolResources = options.toolResources;
    temperature = options.temperature;
    topP = options.topP;
    responseFormat = options.responseFormat ?? ResponseFormat.auto;
    minTokenRequirementPerRequest = options.minTokenRequirementPerRequest;
    maxRequestLength = options.maxRequestLength;
    assistantsFetchCount = options.assistantFetchCount;

    stream = options.stream;
    eventHandler = options.eventHandler;
    _logRunStatusChange = options.logRunStatusChange;
    _saveThreadMessages = options.saveThreadMessages;

    // register event handlers
    assistantProvider.onCreate.listen = onAssistantGet;
    assistantProvider.onRetrieve.listen = onAssistantGet;
    threadProvider.onCreate.listen = onThreadGet;
    threadProvider.onRetrieve.listen = onThreadGet;
    messageProvider.onCreate.listen = onMessageCreated;
    runProvider.onCreate.listen = onRunGet;
    runProvider.onRetrieve.listen = onRunGet;
    runStepProvider.onCreate.listen = onRunStepGet;
    runStepProvider.onRetrieve.listen = onRunStepGet;
  }

  static Future<AssistantsAPIv2> create(
    AssistantsApiOptions options, {
    RunRequest? defaultRunRequest,
  }) async {
    String name = options.name;
    String threadIdKey = "$name.ThreadId";
    String assistantIdKey = "$name.AssistantId";
    String messagesKey = "$name.Messages";
    Prefs<String> savedThreadId = await Prefs.create(threadIdKey);
    Prefs<String> savedAssistantId = await Prefs.create(assistantIdKey);
    PrefsMap<String, Message> savedMessages = await PrefsMap.create(messagesKey);
    Logger logger = options.customLogger ?? OpenAILogger.logger;
    defaultRunRequest ??= new RunRequest();

    return AssistantsAPIv2._internal(
      options,
      savedThreadId,
      savedAssistantId,
      savedMessages,
      defaultRunRequest,
      logger,
    );
  }

  Future<void> init({void Function(void)? onInit}) async {
    updateAPIStatus(AssistantStatus.Initializing);

    await threadProvider.retrieveOrCreate(threadId);
    await Future.delayed(const Duration(milliseconds: MIN_INTERNAL_OPERATION_MILLIS));
    await assistantProvider.retrieveOrCreate(assistantId);

    onInit?.call(null);
    _isInit = true;

    updateAPIStatus(AssistantStatus.WaitingForInput);
    logger.info("Assistant tool initialized successfully.");
  }

  Future<void> cancelRun() async {
    _requiredActions.clear();

    if (run == null || runId.isEmpty) {
      OpenAILogger.error("No run to cancel.");
      onRunStatusChanged(RunStatus.cancelled);

      return;
    }

    run = await OpenAI.instance.run.cancel(threadId, runId);

    if (stream) {
      runManager.waitUntil(RunStatusType.terminal);
    } else {
      await runManager.retrieveRunUntilConditionsAreMetAsync(
        thread,
        run,
        RunCheckType.TerminalCheck,
      );
    }
  }

  Future<void> startNewThread({bool deleteCurrent = false}) async {
    if (deleteCurrent) await DeleteThread(threadId);
    await threadProvider.create();
  }

  Future<void> setCurrentThreadAsync(String threadId) async {
    savedThreadId.value = threadId;
    Thread? thread = await threadProvider.retrieve(threadId);
    onThreadGet(thread);
  }

  Future<void> DeleteThread(String threadId) async {
    bool deleted = await threadProvider.delete(threadId);
    if (deleted) logger.info("Thread deleted successfully.");
  }

  Future<AssistantsApiResult> request(
    String textPrompt, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isFailure) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isFailure) return reqValidationResult;

    return await _handleRequestAsync(
      MessageRequest.create(textPrompt),
      customRunRequest,
    );
  }

  Future<AssistantsApiResult> requestWithImageFiles(
    String textPrompt,
    RunRequest? customRunRequest,
    List<File> imageFiles,
  ) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isFailure) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isFailure) return reqValidationResult;

    return await _handleRequestAsync(
      MessageRequest.withImageFiles(textPrompt, imageFiles),
      customRunRequest,
    );
  }

  Future<AssistantsApiResult> requestWithImageUrls(
    String textPrompt,
    RunRequest? customRunRequest,
    List<String> imageUrls,
  ) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isFailure) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isFailure) return reqValidationResult;

    return await _handleRequestAsync(
      MessageRequest.withImageUrls(textPrompt, imageUrls),
      customRunRequest,
    );
  }

  Future<AssistantsApiResult> requestWithAudioFile(
    File? audioPrompt, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    var promptValidationResult = _validateObjectPrompt(audioPrompt);
    if (promptValidationResult.isFailure) return promptValidationResult;

    var transcriptionRequest = TranscriptionRequest(file: audioPrompt!);

    return await _handleTranscriptionRequestAsync(
      transcriptionRequest,
      customRunRequest,
    );
  }

  Future<AssistantsApiResult> requestWithTranscriptionRequest(
    TranscriptionRequest transcriptionRequest, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    return await _handleTranscriptionRequestAsync(
      transcriptionRequest,
      customRunRequest,
    );
  }

  Future<AssistantsApiResult> requestWithMessageRequest(
    MessageRequest messageRequest, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = _validateAPIStatus();
    if (statusValidationResult.isFailure) return statusValidationResult;

    return await _handleRequestAsync(
      messageRequest,
      customRunRequest,
    );
  }

  Future<void> submitToolOutput(String toolCallId, String outputToSubmit) async {
    try {
      ToolOutput toolOutput = ToolOutput(toolCallId: toolCallId, output: outputToSubmit);

      run = await OpenAI.instance.run.submitToolOutputsToRun(
        thread!.id,
        run!.id,
        output: List.of([toolOutput]),
      );
    } catch (e) {
      await cancelRun();
      throw Exception("Failed to submit tool output. Cancelling the current run...");
    }

    _requiredActions.remove(toolCallId);
    var waitResult = await _waitUntilRequiredActionCompletions();

    if (waitResult.isFailure) {
      throw Exception(waitResult.failReason);
    }
  }

  Future<AssistantsApiResult> handleRequiredAction() async {
    updateAPIStatus(AssistantStatus.RequiresAction);

    var requiredAction = run!.requiredAction;
    if (requiredAction?.submitToolOutputs?.toolCalls == null ||
        requiredAction!.submitToolOutputs!.toolCalls!.isEmpty) {
      return AssistantsApiResult.fail("The run requires action, but no action is specified.");
    }

    var unhandledRequiredActions = <String, RequiredActionStack>{};

    for (ToolCall toolCall in requiredAction.submitToolOutputs!.toolCalls!) {
      if (toolCall.function == null ||
          toolCall.id == null ||
          toolCall.function?.name == null ||
          toolCall.function?.arguments == null) continue;

      var toolCallId = toolCall.id!;
      var arguments = toolCall.function!.arguments!;
      var functionName = toolCall.function!.name!;

      _requiredActions[toolCallId] = RequiredActionStack(functionName, arguments);

      ToolCall? cachedFunctionCall = tools?.firstWhere(
        (x) => x.id == toolCallId && x.function?.delegate != null,
      );

      if (cachedFunctionCall == null) {
        unhandledRequiredActions[toolCallId] = RequiredActionStack(functionName, arguments);
        continue;
      }

      await _executeFunctionDelegate(toolCallId, arguments, cachedFunctionCall.function!.delegate!);
    }

    if (unhandledRequiredActions.isEmpty) {
      updateAPIStatus(AssistantStatus.HandlingResponse);
      var waitResult = await _waitUntilRequiredActionCompletions();
      if (waitResult.isFailure) {
        return AssistantsApiResult.fail(waitResult.failReason);
      }

      return await _getResult();
    }

    return AssistantsApiResult.requiresAction(unhandledRequiredActions);
  }

  void updateAPIStatus(AssistantStatus status) {
    assistantStatus = status;

    String message;
    switch (status) {
      case AssistantStatus.Initializing:
        message = "Initializing the Assistants API ($id).";
        break;
      case AssistantStatus.WaitingForInput:
        message = "The Assistants API is ready.";
        break;
      case AssistantStatus.ProcessingRun:
        message = "Waiting for the run to complete.";
        break;
      case AssistantStatus.RequiresAction:
        message = "Waiting for all required actions to be handled.";
        break;
      case AssistantStatus.HandlingResponse:
        message = "Retrieving the response.";
        break;
      default:
        message = "Unknown stage.";
    }

    logger.info(message);
  }

  void onAssistantGet(Assistant? newAssistant) {
    if (newAssistant == null) return;

    assistant = newAssistant;
    savedAssistantId.value = newAssistant.id;
    eventHandler?.triggerAssistantGet(newAssistant);
  }

  void onThreadGet(Thread? newThread) {
    if (newThread == null) return;

    thread = newThread;
    savedThreadId.value = newThread.id;
    eventHandler?.triggerThreadGet(newThread);
  }

  void onRunGet(Run? newRun) {
    if (newRun == null) return;

    run = newRun;
    eventHandler?.triggerRunGet(newRun);

    RunStatus? newStatus = newRun.status;
    if (newStatus != null) _handleRunStatusChange(newStatus, newRun, null);
  }

  void onRunStepGet(RunStep? newRunStep) {
    if (newRunStep == null) return;

    runStep = newRunStep;
    eventHandler?.triggerRunStepGet(newRunStep);

    RunStatus? newStatus = newRunStep.status;
    if (newStatus != null) _handleRunStatusChange(newStatus, null, newRunStep);
  }

  void onMessageCreated(Message? newMessage) {
    if (newMessage == null) return;

    if (newMessage.role == ChatRole.user) {
      onUserMessageCreated(newMessage);
    } else if (newMessage.role == ChatRole.assistant) {
      onAssistantMessageCreated(newMessage);
    } else if (newMessage.role == ChatRole.tool) {
      onToolMessageCreated(newMessage);
    } else {
      logger.warning("Unknown message role: ${newMessage.role}");
    }

    if (_saveThreadMessages && !threadId.isNullOrEmpty) {
      savedMessages.put(threadId, newMessage);
    }
  }

  void onUserMessageCreated(Message newMessage) {
    if (lastUserMessage == newMessage) return;
    lastUserMessage = newMessage;
    eventHandler?.triggerMessageCreated(newMessage);
  }

  void onAssistantMessageCreated(Message newMessage) {
    if (lastAssistantMessage == newMessage) return;
    lastAssistantMessage = newMessage;
    eventHandler?.triggerMessageCreated(newMessage);
  }

  void onToolMessageCreated(Message newMessage) {
    if (lastToolMessage == newMessage) return;
    lastToolMessage = newMessage;
    eventHandler?.triggerMessageCreated(newMessage);
  }

  void onTextCreated() {
    eventHandler?.triggerTextCreated();
  }

  void onTextDelta(String textDelta) {
    //GNLog.Debug($"Text Delta: {textDelta}");
    eventHandler?.triggerTextDelta(textDelta);
  }

  void onStreamDone() {
    eventHandler?.triggerStreamDone();
  }

  void onToolCallCreated(ToolCall toolCall) {
    eventHandler?.triggerToolCallCreated(toolCall);
  }

  void onToolCallDelta(ToolCall toolCall) {
    eventHandler?.triggerToolCallDelta(toolCall);
  }

  void onMessageCompleted(Message? completedMessage) {
    if (completedMessage == null) {
      logger.error("Message has been completed but is null.");

      return;
    }

    lastAssistantMessage = completedMessage;
    _newAssistantMessageCreated = true;
    eventHandler?.triggerMessageCompleted(completedMessage);
  }

  void onError(String errorMessage) {
    logger.error(errorMessage);
    eventHandler?.triggerError(errorMessage);
  }

  void onRunStatusChanged(RunStatus runStatus) {
    _handleRunStatusChange(runStatus, null, null);
  }

  AssistantsApiResult _validateAPIStatus() {
    if (!_isInit) return AssistantsApiResult.fail("The Assistants API is not initialized.");
    if (requiresAction)
      return AssistantsApiResult.fail(
        "You can only SubmitToolOutputs() if AssistantsAPI requires action to be taken.",
      );
    if (AssistantStatus != AssistantStatus.WaitingForInput)
      return AssistantsApiResult.fail(
        "The Assistants API is not ready. Current status: ${assistantStatus}.",
      );

    return AssistantsApiResult.success();
  }

  AssistantsApiResult _validateTextPrompt(String? textPrompt) {
    if (textPrompt.isNullOrEmpty) return AssistantsApiResult.fail("The input text is empty.");
    logger.info("Requesting with input: ${textPrompt}");

    return AssistantsApiResult.success();
  }

  AssistantsApiResult _validateObjectPrompt<T>(T? objectPrompt) {
    String objectName = objectPrompt?.runtimeType.toString() ?? "Unknown Object";
    if (objectPrompt == null) return AssistantsApiResult.fail("The input ${objectName} is null.");
    logger.info("Requesting with ${objectName} input.");

    return AssistantsApiResult.success();
  }

  AssistantsApiResult _validateRequest() {
    try {
      //tokenValidator?(minTokenRequirementPerRequest);
      tokenValidator?.call(minTokenRequirementPerRequest);
    } catch (e) {
      return AssistantsApiResult.fail(e.toString());
    }

    if (DateTime.now().difference(_lastRequestTime) <
        Duration(milliseconds: MIN_INTERVAL_REQUEST_MILLIS))
      return AssistantsApiResult.fail("The request is too fast. Please wait for a while.");

    return AssistantsApiResult.success();
  }

  Future<AssistantsApiResult> _handleRequestAsync(
    MessageRequest messageRequest,
    RunRequest? customRunRequest,
  ) async {
    if (lastMessageRequest != null && lastMessageRequest == messageRequest) {
      return AssistantsApiResult.fail("The request is the same as the previous request.");
    }

    lastMessageRequest = messageRequest;
    _lastRequestTime = DateTime.now();

    Message? userMessage = await messageProvider.create();
    if (userMessage == null) return AssistantsApiResult.fail("Failed to create a user message.");

    lastRunRequest = customRunRequest ?? defaultRunRequest;

    Run? run = await runProvider.create();
    if (run == null) return AssistantsApiResult.fail("Failed to create a run.");

    bool stream = customRunRequest?.stream ?? this.stream;

    try {
      if (stream) {
        if (eventHandler == null) throw Exception("Event handler is required for stream mode.");
        await runManager.waitUntil(RunStatusType.terminal);
      } else {
        await runManager.createNonStreamResponse();
      }
    } catch (e) {
      return AssistantsApiResult.fail(e.toString());
    }

    return await _getResult();
  }

  Future<AssistantsApiResult> _handleTranscriptionRequestAsync(
    TranscriptionRequest transcriptionRequest,
    RunRequest? customRunRequest,
  ) async {
    AudioObject transcription = await OpenAI.instance.audio.createTranscription(
      file: transcriptionRequest.file,
      model: transcriptionRequest.model,
      prompt: transcriptionRequest.prompt,
      responseFormat: transcriptionRequest.responseFormat,
      temperature: transcriptionRequest.temperature,
      language: transcriptionRequest.language,
      timestamp_granularities: transcriptionRequest.timestampGranularities,
    );

    if (transcription.text.isNullOrEmpty) {
      return AssistantsApiResult.fail("Failed to transcribe the audio file.");
    }

    return await request(transcription.text, customRunRequest: customRunRequest);
  }

  Future<void> _executeFunctionDelegate(
    String toolCallId,
    String arguments,
    FunctionDelegate functionDelegate,
  ) async {
    var result = await functionDelegate.executeInternal(arguments);
    if (result.isFailure || result is! ResultObject<String>) {
      await cancelRun();
      logger.error(
        "Failed to execute the function delegate for the tool call id:$toolCallId with error: ${result.failReason}. Cancelling the current run...",
      );
    }

    String? output = (result as ResultObject<String>).value;
    if (output.isNullOrEmpty) {
      await cancelRun();
      logger.error(
        "Failed to execute the function delegate for the tool call id:$toolCallId. The output is null or empty. Cancelling the current run...",
      );
    }

    await submitToolOutput(toolCallId, result.value!);
  }

  Future<AssistantsApiResult> _getResult() async {
    if (runStatus == RunStatus.requires_action) {
      return await handleRequiredAction();
    }

    return _buildFinalResult();
  }

  AssistantsApiResult _buildFinalResult() {
    if (!_newAssistantMessageCreated)
      return AssistantsApiResult.fail("No new assistant message created.");
    if (lastAssistantMessage == null)
      return AssistantsApiResult.fail("Failed to retrieve the result from the run.");
    var usage = run!.usage;
    if (usage != null) usageHandler?.call(usage);

    return AssistantsApiResult.message(lastAssistantMessage!, usage: usage);
  }

  Future<Result> _waitUntilRequiredActionCompletions() async {
    if (_waitingForRequiredActionCompletions)
      return Result.fail("Already waiting for required action completions.");
    _waitingForRequiredActionCompletions = true;

    var runExpirationTime = DateTime.now().add(Duration(minutes: 30));

    await Future.doWhile(() {
      Future.delayed(Duration(seconds: 1));

      return _requiredActions.isNotEmpty && DateTime.now().isBefore(runExpirationTime);
    });

    _waitingForRequiredActionCompletions = false;

    if (DateTime.now().isAfter(runExpirationTime)) {
      return Result.fail("The run has expired. Cancelling the current run...");
    }

    return Result.success();
  }

  void _handleRunStatusChange(RunStatus runStatus, Run? newRun, RunStep? newRunStep) {
    if (RunStatus == runStatus) return;
    this.runStatus = runStatus;
    _logRunStatus(runStatus);

    switch (runStatus) {
      case RunStatus.queued:
      case RunStatus.in_progress:
      case RunStatus.cancelling:
        updateAPIStatus(AssistantStatus.ProcessingRun);
        break;

      case RunStatus.requires_action:
        // TODO: I don't understand this fully yet.
        // This is pseudo code for now.
        if (newRun != null && newRun.tools != null && newRun.tools!.isNotEmpty) {
          for (var tool in newRun.tools!) {
            onToolCallCreated(tool);
          }
        }

        updateAPIStatus(AssistantStatus.RequiresAction);
        break;

      case RunStatus.completed:
      case RunStatus.expired:
      case RunStatus.cancelled:
        updateAPIStatus(AssistantStatus.WaitingForInput);
        break;

      case RunStatus.failed:
        LastError? lastError;
        if (newRun != null)
          lastError = newRun.lastError;
        else if (newRunStep != null) lastError = newRunStep.lastError;

        if (lastError != null && !lastError.message.isNullOrEmpty) {
          logger.error(lastError.message!);
          onError(lastError.message!);
        }

        updateAPIStatus(AssistantStatus.WaitingForInput);
        break;

      case RunStatus.incomplete:
        IncompleteDetails? incompleteDetails = newRun?.incompleteDetails;
        if (incompleteDetails != null && !incompleteDetails.reason.isNullOrEmpty) {
          logger.error(incompleteDetails.reason!);
          onError(incompleteDetails.reason!);
        }

        updateAPIStatus(AssistantStatus.WaitingForInput);
        break;

      default:
        updateAPIStatus(AssistantStatus.Initializing);
        break;
    }

    eventHandler?.triggerRunStatusChanged(runStatus);
  }

  void _logRunStatus(RunStatus runStatus) {
    if (!_logRunStatusChange) return;
    logger.info("Run Status Changed: $runStatus");
  }
}
