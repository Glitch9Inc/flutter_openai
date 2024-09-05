import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/config/openai_strings.dart';

class OpenAILogSettings extends LogSettings {
  static const int _kValidApiKeyLength = 10;
  final Logger _mainLogger = new Logger(OpenAIStrings.openai);
  bool showRunStatus;

  OpenAILogSettings(
      {super.enabled = true,
      super.showRequestHeaders = false,
      super.showRequestBody = false,
      super.showResponseBody = false,
      super.hideEmptyBody = true,
      super.showRedirections = false,
      this.showRunStatus = false});

  void info(String message, [Object? error]) {
    _mainLogger.info(message);
  }

  void warning(String message) {
    _mainLogger.warning(message);
  }

  void severe(String errorMessage) {
    _mainLogger.severe(errorMessage);
  }

  /// Logs that an api key is being set, if the logger is active.
  void logAPIKey([String? apiKey]) {
    if (apiKey != null && isValidApiKey(apiKey)) {
      final hiddenApiKey = apiKey.replaceRange(0, apiKey.length - 10, '****');
      _mainLogger.info("api key set to $hiddenApiKey");
    } else {
      _mainLogger.severe("api key is set but not valid");
    }
  }

  /// Logs that an organization id is being set, if the logger is active.
  void logOrganization(String? organizationId) {
    _mainLogger.info("organization id set to $organizationId");
  }

  /// Logs that an baseUrl key is being set, if the logger is active.
  void logBaseUrl([String? baseUrl]) {
    if (baseUrl != null) {
      _mainLogger.info("base url set to $baseUrl");
    } else {
      _mainLogger.info("base url is set");
    }
  }

  /// simple check for api key validity
  static isValidApiKey(String key) {
    return key.isNotEmpty && key.startsWith("sk-") && key.length > _kValidApiKeyLength;
  }
}
