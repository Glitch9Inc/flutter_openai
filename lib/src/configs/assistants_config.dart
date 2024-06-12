abstract class AssistantsConfig {
  static const int initialDelayForRunStatusCheckSec = 5;
  static const int recurringRunStatusCheckIntervalSec = 2;
  static const int runOperationTimeoutSec = 90;
  static const bool useTokenValidationForRun = false;
  static const int assistantFetchCount = 20;
  static const int maxPromptTokensForRunRequests = -1;
  static const int maxCompletionTokensForRunRequests = -1;
}
