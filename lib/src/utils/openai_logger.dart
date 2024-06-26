import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../configs/openai_strings.dart';

@protected
@immutable
@internal
abstract final class OpenAILogger {
  static Logger logger = new Logger(OpenAIStrings.openai);

  /// The valid min length of an api key.
  static const int _kValidApiKeyLength = 10;

  static bool _isActive = true;
  static bool _showRequestHeaderLogs = false;
  static bool _showRequestBodyLogs = false;
  static bool _showResponseBodyLogs = false;
  static bool _showRunStatusLogs = true;

  static bool get isActive => _isActive;
  static bool get showHeadersLogs => _showRequestHeaderLogs;
  static bool get showRequestBodyLogs => _showRequestBodyLogs;
  static bool get showResponseBodyLogs => _showResponseBodyLogs;
  static bool get showRunStatusLogs => _showRunStatusLogs;

  static set isActive(bool newValue) {
    _isActive = newValue;
  }

  static set showHeadersLogs(bool newValue) {
    _showRequestHeaderLogs = newValue;
  }

  static set showRequestBodyLogs(bool newValue) {
    _showRequestBodyLogs = newValue;
  }

  static set showResponseBodyLogs(bool newValue) {
    _showResponseBodyLogs = newValue;
  }

  static set showRunStatusLogs(bool newValue) {
    _showRunStatusLogs = newValue;
  }

  /// Logs a message, if the logger is active.
  static void log(String message, [Object? error]) {
    if (_isActive) {
      logger.info(message);
    }
  }

  static void error(String errorMessage) {
    if (_isActive) {
      logger.info(errorMessage);
    }
  }

  static void logRequestBody(String encodedBody) {
    if (_isActive && _showRequestBodyLogs) {
      log("RequestBody: $encodedBody");
    }
  }

  /// Logs the response of a request, if the logger is active.
  static void logResponseBody(response) {
    if (_isActive && _showResponseBodyLogs) {
      if (response is Response) {
        logger.info("ResponseBody: ${response.body.toString()}");
      } else {
        logger.info(
          "ResponseBody: ${response.toString()}",
        );
      }
    }
  }

  /// Logs that a request to an [endpoint] is being made, if the logger is active.
  static void logEndpoint(String endpoint) {
    log("accessing endpoint: $endpoint");
  }

  /// Logs that an api key is being set, if the logger is active.
  static void logAPIKey([String? apiKey]) {
    if (apiKey != null && isValidApiKey(apiKey)) {
      final hiddenApiKey = apiKey.replaceRange(0, apiKey.length - 10, '****');
      log("api key set to $hiddenApiKey");
    } else {
      log("api key is set but not valid");
    }
  }

  /// simple check for api key validity
  static isValidApiKey(String key) {
    return key.isNotEmpty && key.startsWith("sk-") && key.length > _kValidApiKeyLength;
  }

  /// Logs that an baseUrl key is being set, if the logger is active.
  static void logBaseUrl([String? baseUrl]) {
    if (baseUrl != null) {
      log("base url set to $baseUrl");
    } else {
      log("base url is set");
    }
  }

  /// Logs that an organization id is being set, if the logger is active.
  static void logOrganization(String? organizationId) {
    log("organization id set to $organizationId");
  }

  static void logStartRequest(String method, String from) {
    return log("starting $method request to $from");
  }

  static void requestToWithStatusCode(Uri uri, int statusCode) {
    return log("request to $uri finished with status code ${statusCode}");
  }

  static void startingDecoding() {
    return log("starting decoding response body");
  }

  static void decodedSuccessfully() {
    return log("response body decoded successfully");
  }

  static void errorOcurred([Object? error]) {
    return log("an error occurred, throwing exception: $error");
  }

  static void requestFinishedSuccessfully() {
    return log("request finished successfully");
  }

  static void streamResponseDone() {
    return log("stream response is done");
  }

  static void startReadStreamResponse() {
    return log("Starting to reading stream response");
  }

  static void logHeaders(
    Map<String, dynamic> additionalHeadersToRequests,
  ) {
    if (_isActive && _showRequestHeaderLogs) {
      for (int index = 0; index < additionalHeadersToRequests.entries.length; index++) {
        final entry = additionalHeadersToRequests.entries.elementAt(index);
        log("header: ${entry.key}:${entry.value}");
      }
    }
  }

  static void startingTryCheckingForError() {
    return log("starting to check for error in the response.");
  }

  static void errorFoundInRequest() {
    return log("error found in request, throwing exception");
  }

  static void unexpectedResponseGotten() {
    return log(
      "unexpected response gotten, this means that a change is made to the api, please open an issue on github",
    );
  }

  static void noErrorFound() {
    return log("Good, no error found in response.");
  }

  static void creatingFile(String fileName) {
    return log("creating output file: $fileName");
  }

  static void fileCreatedSuccessfully(String fileName) {
    return log("file $fileName created successfully");
  }

  static void writingFileContent(String fileName) {
    return log("writing content to file $fileName");
  }

  static void fileContentWrittenSuccessfully(String fileName) {
    return log("content written to file $fileName successfully");
  }

  static void requestsTimeoutChanged(Duration requestsTimeOut) {
    return log("requests timeout changed to $requestsTimeOut");
  }

  static void logIsWeb(bool isWeb) {
    return log("isWeb set to $isWeb");
  }

  static void tryingToRetrieveObject(String objectName) {
    return log("trying to retrieve $objectName");
  }

  static void failedToRetrieveObject(String objectName) {
    return log("failed to retrieve $objectName");
  }

  static void creatingNewObject(String objectName) {
    return log("creating new $objectName");
  }

  static void errorCreatingObject(String objectName) {
    return log("error creating $objectName");
  }

  static void isBetaRequest() {
    return log("this is a beta request");
  }

  static void logRunStatus(RunStatus? runStatus) {
    if (_isActive && _showRunStatusLogs) {
      if (runStatus == null) runStatus = RunStatus.unknown;

      log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────");
      log("│ RUN STATUS: $runStatus");
      log("└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────");
    }
  }
}
