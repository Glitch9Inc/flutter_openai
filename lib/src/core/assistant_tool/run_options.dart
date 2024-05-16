class RunOptions {
  int initialDelayForStateCheckSec = 5;
  int recurringStateCheckIntervalSec = 5;
  int operationTimeoutSec = 90;
  int assistantsFetchCount = 20;
  int minTokenCountForRequests = -1;

  static RunOptions get defaultOptions => RunOptions();

  RunOptions();
}
