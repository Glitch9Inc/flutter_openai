import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_corelib/flutter_corelib.dart' hide ExceptionHandler;
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/model/assistant_event_handler.dart';
import 'package:flutter_openai/src/assistants_api_v2/client/assistants_api_v2_util.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/assistant_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/message_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/run_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/run_step_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_provider/thread_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/model/request/message_request.dart';
import 'package:flutter_openai/src/assistants_api_v2/controller/run_controller.dart';
import 'package:flutter_openai/src/assistants_api_v2/model/run_status_type.dart';
import '../model/request/transcription_request.dart';
import '../model/required_action_stack.dart';

export 'package:flutter_openai/src/assistants_api_v2/model/assistant_options.dart';
export 'package:flutter_openai/src/assistants_api_v2/model/assistant_result.dart';
export 'package:flutter_openai/src/assistants_api_v2/model/request/run_request.dart';

enum AssistantStatus {
  Initializing,
  InitializationFailed,
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
  final Logger logger = Logger("AssistantsAPIv2");

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
  String? initializationFailedReason;

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
  AssistantStatus status = AssistantStatus.Initializing;
  bool stream = false;

  // Providers & Managers
  AssistantProvider? _assistantProvider;
  ThreadProvider? _threadProvider;
  MessageProvider? _messageProvider;
  RunProvider? _runProvider;
  RunStepProvider? _runStepProvider;
  RunController? _runManager;

  bool _logRunStatusChange = true;
  bool _saveThreadMessages = false;

  DateTime _lastRequestTime = DateTime.now();
  Map<String, RequiredActionStack> _requiredActions = new Map<String, RequiredActionStack>();
  bool _waitingForRequiredActionCompletions = false;
  bool _newAssistantMessageCreated = false;

  AssistantProvider get assistantProvider => _assistantProvider!;
  ThreadProvider get threadProvider => _threadProvider!;
  MessageProvider get messageProvider => _messageProvider!;
  RunProvider get runProvider => _runProvider!;
  RunStepProvider get runStepProvider => _runStepProvider!;
  RunController get runManager => _runManager!;

  String get assistantId => savedAssistantId.value ?? assistant?.id ?? '';
  String get threadId => savedThreadId.value ?? thread?.id ?? '';
  String get runId => run?.id ?? '';
  bool get requiresAction => runStatus == RunStatus.requires_action;

  AssistantsAPIv2._internal(
    AssistantOptions options,
    this.savedThreadId,
    this.savedAssistantId,
    this.savedMessages,
    this.defaultRunRequest,
  ) {
    logger.info("Creating AssistantsAPIv2 instance...");

    // late initialization
    _assistantProvider = AssistantProvider(this);
    _threadProvider = ThreadProvider(this);
    _messageProvider = MessageProvider(this);
    _runProvider = RunProvider(this);
    _runStepProvider = RunStepProvider(this);
    _runManager = RunController(this, options);

    tokenValidator = options.tokenValidator;
    usageHandler = options.usageHandler;
    exceptionHandler = options.exceptionHandler;

    id = options.id;
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
    assistantProvider.onCreate.listen(onAssistantGet);
    assistantProvider.onRetrieve.listen(onAssistantGet);
    threadProvider.onCreate.listen(onThreadGet);
    threadProvider.onRetrieve.listen(onThreadGet);
    messageProvider.onCreate.listen(onMessageCreated);
    runProvider.onCreate.listen(onRunGet);
    runProvider.onRetrieve.listen(onRunGet);
    runStepProvider.onCreate.listen(onRunStepGet);
    runStepProvider.onRetrieve.listen(onRunStepGet);

    logger.info("AssistantsAPIv2 instance created successfully.");
  }

  static Future<AssistantsAPIv2> create(
    AssistantOptions options, {
    RunRequest? defaultRunRequest,
  }) async {
    String name = options.name;
    String threadIdKey = "$name.ThreadId";
    String assistantIdKey = "$name.AssistantId";
    String messagesKey = "$name.Messages";
    Prefs<String> savedThreadId = await Prefs.create(threadIdKey);
    Prefs<String> savedAssistantId = await Prefs.create(assistantIdKey);
    PrefsMap<String, Message> savedMessages = await PrefsMap.create(messagesKey);
    defaultRunRequest ??= new RunRequest();

    var api = AssistantsAPIv2._internal(
      options,
      savedThreadId,
      savedAssistantId,
      savedMessages,
      defaultRunRequest,
    );
    await api.init();
    return api;
  }

  Future<void> init() async {
    AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.Initializing);

    try {
      await threadProvider.retrieveOrCreate(threadId);
      await Future.delayed(const Duration(milliseconds: MIN_INTERNAL_OPERATION_MILLIS));
      await assistantProvider.retrieveOrCreate(assistantId);

      List<Run> runsOnThread = await runProvider.list(assistantsFetchCount);
      // cancel all runs that are not in terminal state

      for (Run run in runsOnThread) {
        if (!run.status.isStatusType(RunStatusType.terminal)) {
          await OpenAI.instance.run.cancel(threadId, run.id);
        }
      }
    } catch (e) {
      initializationFailedReason = e.toString();
      AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.InitializationFailed);
      logger.severe("Failed to initialize the assistant tool: $e");
      return;
    }

    AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.WaitingForInput);
    logger.info("Assistant tool initialized successfully.");
  }

  Future<void> cancelRun() async {
    _requiredActions.clear();

    if (run == null || runId.isEmpty) {
      logger.severe("No run to cancel.");
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

  Future<AssistantResult> request(
    String textPrompt, {
    List<String>? fileIds,
    RunRequest? customRunRequest,
    String? additionalInstructions,
  }) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

    if (threadId.isNullOrEmpty) return AssistantResult.error("The thread id is empty.");

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isError) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isError) return reqValidationResult;

    if (customRunRequest == null && additionalInstructions != null) {
      customRunRequest = lastRunRequest ?? defaultRunRequest;
      customRunRequest.additionalInstructions = additionalInstructions;
    }

    return await _handleRequestAsync(
      MessageRequest.create(textPrompt, fileIds: fileIds),
      customRunRequest,
    );
  }

  Future<AssistantResult> requestWithImageFiles(
    String textPrompt,
    RunRequest? customRunRequest,
    List<io.File> imageFiles,
  ) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isError) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isError) return reqValidationResult;

    return await _handleRequestAsync(
      MessageRequest.withImageFiles(textPrompt, imageFiles),
      customRunRequest,
    );
  }

  Future<AssistantResult> requestWithImageUrls(
    String textPrompt,
    RunRequest? customRunRequest,
    List<String> imageUrls,
  ) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

    var promptValidationResult = _validateTextPrompt(textPrompt);
    if (promptValidationResult.isError) return promptValidationResult;

    var reqValidationResult = _validateRequest();
    if (reqValidationResult.isError) return reqValidationResult;

    return await _handleRequestAsync(
      MessageRequest.withImageUrls(textPrompt, imageUrls),
      customRunRequest,
    );
  }

  Future<AssistantResult> requestWithAudioFile(
    io.File? audioPrompt, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

    var promptValidationResult = _validateObjectPrompt(audioPrompt);
    if (promptValidationResult.isError) return promptValidationResult;

    var transcriptionRequest = TranscriptionRequest(file: audioPrompt!);

    return await _handleTranscriptionRequestAsync(
      transcriptionRequest,
      customRunRequest,
    );
  }

  Future<AssistantResult> requestWithTranscriptionRequest(
    TranscriptionRequest transcriptionRequest, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

    return await _handleTranscriptionRequestAsync(
      transcriptionRequest,
      customRunRequest,
    );
  }

  Future<AssistantResult> requestWithMessageRequest(
    MessageRequest messageRequest, {
    RunRequest? customRunRequest,
  }) async {
    var statusValidationResult = AssistantsAPIv2Util.validateAPIStatus(this);
    if (statusValidationResult.isError) return statusValidationResult;

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

    if (waitResult.isError) {
      throw Exception(waitResult.message);
    }
  }

  Future<AssistantResult> handleRequiredAction() async {
    AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.RequiresAction);

    var requiredAction = run!.requiredAction;
    if (requiredAction?.submitToolOutputs?.toolCalls == null || requiredAction!.submitToolOutputs!.toolCalls!.isEmpty) {
      return AssistantResult.error("The run requires action, but no action is specified.");
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
      AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.HandlingResponse);
      var waitResult = await _waitUntilRequiredActionCompletions();
      if (waitResult.isError) {
        return AssistantResult.error(waitResult.message);
      }

      return await _getResult();
    }

    return AssistantResult.requiresAction(unhandledRequiredActions);
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
    if (newMessage.content == null) {
      logger.severe("New Assistant Message Content is null.");
      return;
    }
    logger.info("New Assistant Message Created: ${newMessage.content}");
    _newAssistantMessageCreated = true;
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
      logger.severe("Message has been completed but is null.");

      return;
    }

    lastAssistantMessage = completedMessage;
    _newAssistantMessageCreated = true;
    eventHandler?.triggerMessageCompleted(completedMessage);
  }

  void onError(String errorMessage) {
    logger.severe(errorMessage);
    eventHandler?.triggerError(errorMessage);
  }

  void onRunStatusChanged(RunStatus runStatus) {
    _handleRunStatusChange(runStatus, null, null);
  }

  AssistantResult _validateTextPrompt(String? textPrompt) {
    if (textPrompt.isNullOrEmpty) return AssistantResult.error("The input text is empty.");
    logger.info("Requesting with input: ${textPrompt}");

    return AssistantResult.success();
  }

  AssistantResult _validateObjectPrompt<T>(T? objectPrompt) {
    String objectName = objectPrompt?.runtimeType.toString() ?? "Unknown Object";
    if (objectPrompt == null) return AssistantResult.error("The input ${objectName} is null.");
    logger.info("Requesting with ${objectName} input.");

    return AssistantResult.success();
  }

  AssistantResult _validateRequest() {
    try {
      //tokenValidator?(minTokenRequirementPerRequest);
      tokenValidator?.call(minTokenRequirementPerRequest);
    } catch (e) {
      return AssistantResult.error(e.toString());
    }

    if (DateTime.now().difference(_lastRequestTime) < Duration(milliseconds: MIN_INTERVAL_REQUEST_MILLIS))
      return AssistantResult.error("The request is too fast. Please wait for a while.");

    return AssistantResult.success();
  }

  Future<AssistantResult> _handleRequestAsync(
    MessageRequest messageRequest,
    RunRequest? customRunRequest,
  ) async {
    if (lastMessageRequest != null && lastMessageRequest == messageRequest) {
      return AssistantResult.error("The request is the same as the previous request.");
    }

    logger.shout("Handling the AssistantsApi-v2 request...");

    lastMessageRequest = messageRequest;
    _lastRequestTime = DateTime.now();

    Message? userMessage = await messageProvider.create();
    if (userMessage == null) return AssistantResult.error("Failed to create a user message.");

    lastRunRequest = customRunRequest ?? defaultRunRequest;

    run = await runProvider.create();
    if (run == null) return AssistantResult.error("Failed to create a run.");

    bool stream = customRunRequest?.stream ?? this.stream;

    try {
      if (stream) {
        if (eventHandler == null) throw Exception("Event handler is required for stream mode.");
        await runManager.waitUntil(RunStatusType.terminal);
      } else {
        await runManager.createNonStreamResponse();
      }
    } catch (e) {
      return AssistantResult.error(e.toString());
    }

    return await _getResult();
  }

  Future<AssistantResult> _handleTranscriptionRequestAsync(
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
      return AssistantResult.error("Failed to transcribe the audio file.");
    }

    return await request(transcription.text, customRunRequest: customRunRequest);
  }

  Future<void> _executeFunctionDelegate(
    String toolCallId,
    String arguments,
    FunctionDelegate functionDelegate,
  ) async {
    var result = await functionDelegate.executeInternal(arguments);
    if (result.isError || result is! Result<String>) {
      await cancelRun();
      logger.severe(
        "Failed to execute the function delegate for the tool call id:$toolCallId with error: ${result.message}. Cancelling the current run...",
      );
    }

    String? output = (result as Result<String>).data;
    if (output.isNullOrEmpty) {
      await cancelRun();
      logger.severe(
        "Failed to execute the function delegate for the tool call id:$toolCallId. The output is null or empty. Cancelling the current run...",
      );
    }

    await submitToolOutput(toolCallId, result.data!);
  }

  Future<AssistantResult> _getResult() async {
    if (runStatus == RunStatus.requires_action) {
      return await handleRequiredAction();
    }

    return _buildFinalResult();
  }

  AssistantResult _buildFinalResult() {
    if (!_newAssistantMessageCreated) return AssistantResult.error("No new assistant message created.");
    if (lastAssistantMessage == null) return AssistantResult.error("Failed to retrieve the result from the run.");
    var usage = run!.usage;
    if (usage != null) usageHandler?.call(usage);

    return AssistantResult.message(lastAssistantMessage!, usage: usage);
  }

  Future<Result> _waitUntilRequiredActionCompletions() async {
    if (_waitingForRequiredActionCompletions) return Result.error("Already waiting for required action completions.");
    _waitingForRequiredActionCompletions = true;

    var runExpirationTime = DateTime.now().add(Duration(minutes: 30));

    await Future.doWhile(() {
      Future.delayed(Duration(seconds: 1));

      return _requiredActions.isNotEmpty && DateTime.now().isBefore(runExpirationTime);
    });

    _waitingForRequiredActionCompletions = false;

    if (DateTime.now().isAfter(runExpirationTime)) {
      return Result.error("The run has expired. Cancelling the current run...");
    }

    return Result.success("All required actions have been handled.");
  }

  void _handleRunStatusChange(RunStatus runStatus, Run? newRun, RunStep? newRunStep) {
    if (RunStatus == runStatus) return;
    this.runStatus = runStatus;
    _logRunStatus(runStatus);

    switch (runStatus) {
      case RunStatus.queued:
      case RunStatus.in_progress:
      case RunStatus.cancelling:
        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.ProcessingRun);
        break;

      case RunStatus.requires_action:
        // TODO: I don't understand this fully yet.
        // This is pseudo code for now.
        if (newRun != null && newRun.tools != null && newRun.tools!.isNotEmpty) {
          for (var tool in newRun.tools!) {
            onToolCallCreated(tool);
          }
        }

        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.RequiresAction);
        break;

      case RunStatus.completed:
      case RunStatus.expired:
      case RunStatus.cancelled:
        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.WaitingForInput);
        break;

      case RunStatus.failed:
        LastError? lastError;
        if (newRun != null)
          lastError = newRun.lastError;
        else if (newRunStep != null) lastError = newRunStep.lastError;

        if (lastError != null && !lastError.message.isNullOrEmpty) {
          logger.severe(lastError.message!);
          onError(lastError.message!);
        }

        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.WaitingForInput);
        break;

      case RunStatus.incomplete:
        IncompleteDetails? incompleteDetails = newRun?.incompleteDetails;
        if (incompleteDetails != null && !incompleteDetails.reason.isNullOrEmpty) {
          logger.severe(incompleteDetails.reason!);
          onError(incompleteDetails.reason!);
        }

        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.WaitingForInput);
        break;

      default:
        AssistantsAPIv2Util.updateAPIStatus(this, AssistantStatus.Initializing);
        break;
    }

    eventHandler?.triggerRunStatusChanged(runStatus);
  }

  void _logRunStatus(RunStatus runStatus) {
    if (!_logRunStatusChange) return;
    logger.info("Run Status Changed: $runStatus");
  }
}
