import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/assistant_event_handler.dart';
import 'package:flutter_openai/src/configs/assistants_config.dart';

class AssistantsApiOptions {
  final String id;
  final GPTModel model;
  final String name;
  final String description;
  final String instructions;
  final List<ToolCall>? tools;
  final ToolResources? toolResources;
  final ToolChoice? forcedTool;
  final Map<String, String>? metadata;
  final double? temperature;
  final double? topP;
  final ResponseFormat? responseFormat;
  final bool stream;
  final int minTokenRequirementPerRequest;
  final int maxRequestLength;
  final int assistantFetchCount;
  final int initialDelayForRunStatusCheckSec;
  final int recurringRunStatusCheckIntervalSec;
  final int runOperationTimeoutSec;
  final bool saveThreadMessages;
  final bool logRunStatusChange;
  final AssistantEventHandler? eventHandler;
  final TokenValidator? tokenValidator;
  final UsageHandler? usageHandler;
  final ExceptionHandler? exceptionHandler;
  final Logger? customLogger;

  bool get isValid =>
      id.isNotEmpty &&
      name.isNotEmpty &&
      description.isNotEmpty &&
      instructions.isNotEmpty &&
      (maxRequestLength >= 0 || maxRequestLength == -1);

  AssistantsApiOptions({
    required this.id,
    required this.model,
    required this.name,
    required this.description,
    required this.instructions,
    this.tools,
    this.toolResources,
    this.forcedTool,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
    this.stream = false,
    this.minTokenRequirementPerRequest = -1,
    this.maxRequestLength = -1,
    this.assistantFetchCount = AssistantsConfig.assistantFetchCount,
    this.initialDelayForRunStatusCheckSec = AssistantsConfig.initialDelayForRunStatusCheckSec,
    this.recurringRunStatusCheckIntervalSec = AssistantsConfig.recurringRunStatusCheckIntervalSec,
    this.runOperationTimeoutSec = AssistantsConfig.runOperationTimeoutSec,
    this.saveThreadMessages = false,
    this.logRunStatusChange = true,
    this.eventHandler,
    this.tokenValidator,
    this.usageHandler,
    this.exceptionHandler,
    this.customLogger,
  });
}
