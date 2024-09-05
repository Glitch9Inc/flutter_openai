import 'package:flutter_openai/flutter_openai.dart';

abstract class AssistantsAPIv2Util {
  static AssistantResult validateAPIStatus(AssistantsAPIv2 api) {
    if (api.status == AssistantStatus.InitializationFailed) {
      return AssistantResult.error(
          "The Assistants API failed to initialize: ${api.initializationFailedReason ?? "unknown reason"}.");
    }
    if (api.requiresAction)
      return AssistantResult.error(
        "You can only SubmitToolOutputs() if AssistantsAPI requires action to be taken.",
      );
    if (api.status != AssistantStatus.WaitingForInput)
      return AssistantResult.error(
        "The Assistants API is not ready. Current status: ${api.status}.",
      );

    return AssistantResult.success();
  }

  static void updateAPIStatus(AssistantsAPIv2 api, AssistantStatus status) {
    api.status = status;
    String id = api.id ?? "unknown";

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

    api.logger.info(message);
  }
}
