import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

import 'configs/headers.dart';
import 'configs/object_types.dart';
import 'configs/openai_config.dart';
import 'configs/openai_endpoints.dart';
import 'configs/openai_http.dart';

typedef TokenValidator = void Function(int);
typedef UsageHandler = void Function(Usage);
typedef ExceptionHandler = void Function(Exception);

/// The main class of the package. It is a singleton class, so you can only have one instance of it.
/// You can also access the instance by calling the [OpenAI.instance] getter.
/// ```dart
/// final openai = OpenAI.instance;
/// ```
@immutable
final class OpenAI {
  static final endpoint = OpenAIEndpoints.instance;
  static final httpMethod = OpenAIHttp.instance;
  static final type = OpenAIObjectTypes.instance;

  /// The singleton instance of [OpenAI].
  static final OpenAI _instance = OpenAI._();

  /// The API key used to authenticate the requests.
  static String? _internalApiKey;

  /// The singleton instance of [OpenAI], make sure to set your OpenAI API key via the [OpenAI.apiKey] setter before accessing the [OpenAI.instance], otherwise it will throw an [Exception].
  /// A [MissingApiKeyException] will be thrown, if the API key is not set.
  static OpenAI get instance {
    if (_internalApiKey == null) {
      throw MissingApiKeyException("""
      You must set the api key before accessing the instance of this class.
      Example:
      OpenAI.apiKey = "Your API Key";
      """);
    }

    return _instance;
  }

  /// {@macro openai_config_requests_timeOut}
  static Duration get requestsTimeOut => OpenAIConfig.requestsTimeOut;

  // /// {@macro openai_config_is_web}
  // static bool get isWeb => OpenAIConfig.isWeb;

  /// The [ModelService] instance, used to access the model endpoints.
  /// Please, refer to the Models page from the official OpenAI documentation website in order to know what models are available and what's the use case of every model.
  ModelService get model => ModelService();

  /// The [ImageService] instance, used to access the images endpoints.
  ImageService get image => ImageService();

  /// The [EmbeddingService] instance, used to access the embeddings endpoints.
  EmbeddingService get embedding => EmbeddingService();

  /// The [FileService] instance, used to access the files endpoints.
  FileService get file => FileService();

  /// The [FineTuningService] instance, used to access the fine-tunes endpoints.
  FineTuningService get fineTuning => FineTuningService();

  /// The [ModerationService] instance, used to access the moderation endpoints.
  ModerationService get moderation => ModerationService();

  /// The [ChatCompletionService] instance, used to access the chat endpoints.
  ChatCompletionService get chatCompletion => ChatCompletionService();

  /// The [AudioService] instance, used to access the audio endpoints.
  AudioService get audio => AudioService();

  /// The [AssistantService] instance, used to access the assistants endpoints.
  AssistantService get assistant => AssistantService();

  /// The [ThreadService] instance, used to access the threads endpoints.
  ThreadService get thread => ThreadService();

  /// The [MessageService] instance, used to access the messages endpoints.
  MessageService get message => MessageService();

  /// The [RunService] instance, used to access the runs endpoints.
  RunService get run => RunService();

  /// The [RunStepService] instance, used to access the run steps endpoints.
  RunStepService get runStep => RunStepService();

  /// The organization id, if set, it will be used in all the requests to the OpenAI API.
  static String? get organization => HeadersBuilder.organization;

  /// The base API url, by default it is set to the OpenAI API url.
  /// You can change it by calling the [OpenAI.baseUrl] setter.
  static String get baseUrl => OpenAIConfig.baseUrl;

  /// {@macro openai_config_requests_timeOut}
  static set requestsTimeOut(Duration requestsTimeOut) {
    OpenAIConfig.requestsTimeOut = requestsTimeOut;
    OpenAILogger.requestsTimeoutChanged(requestsTimeOut);
  }

  /// This is used to initialize the [OpenAI] instance, by providing the API key.
  /// All the requests will be authenticated using this API key.
  /// ```dart
  /// OpenAI.apiKey = "YOUR_API_KEY";
  /// ```
  static set apiKey(String apiKey) {
    HeadersBuilder.apiKey = apiKey;
    _internalApiKey = apiKey;
  }

  /// This is used to set the base url of the OpenAI API, by default it is set to [OpenAIConfig.baseUrl].
  static set baseUrl(String baseUrl) {
    OpenAIConfig.baseUrl = baseUrl;
  }

  /// If you have multiple organizations, you can set it's id with this.
  /// once this is set, it will be used in all the requests to the OpenAI API.
  ///
  /// Example:
  ///
  /// ```dart
  /// OpenAI.organization = "YOUR_ORGANIZATION_ID";
  /// ```
  static set organization(String? organizationId) {
    HeadersBuilder.organization = organizationId;
  }

  /// This controls whether to log steps inside the process of making a request, this helps debugging and pointing where something went wrong.
  /// This uses  [dart:developer] internally, so it will show anyway only while debugging code.
  ///
  /// By default it is set to [true].
  ///
  /// Example:
  /// ```dart
  /// OpenAI.instance.showLogs = false;
  /// ```
  static set showLogs(bool newValue) {
    OpenAILogger.isActive = newValue;
  }

  /// This controls whether to log request headers or not.
  /// This uses  [dart:developer] internally, so it will show anyway only while debugging code.
  ///
  /// By default it is set to [false].
  ///
  /// Example:
  /// ```dart
  /// OpenAI.showHeadersLogs = true;
  /// ```
  static set showRequestHeaderLogs(bool showHeadersLogs) {
    OpenAILogger.showHeadersLogs = showHeadersLogs;
  }

  /// This controls whether to log request bodies or not.
  /// This uses  [dart:developer] internally, so it will show anyway only while debugging code.
  ///
  /// By default it is set to [false].
  ///
  /// Example:
  /// ```dart
  /// OpenAI.showRequestBodyLogs = true;
  /// ```
  static set showRequestBodyLogs(bool showRequestBodyLogs) {
    OpenAILogger.showRequestBodyLogs = showRequestBodyLogs;
  }

  /// This controls whether to log responses bodies or not.
  /// This uses  [dart:developer] internally, so it will show anyway only while debugging code.
  ///
  /// By default it is set to [false].
  ///
  /// Example:
  /// ```dart
  /// OpenAI.showResponsesLogs = true;
  /// ```
  static set showResponseBodyLogs(bool showResponseBodyLogs) {
    OpenAILogger.showResponseBodyLogs = showResponseBodyLogs;
  }

  /// This controls whether to log run status changes or not.
  /// This uses  [dart:developer] internally, so it will show anyway only while debugging code.
  ///
  /// By default it is set to [true].
  ///
  /// Example:
  ///
  /// ```dart
  /// OpenAI.showRunStatusLogs = false;
  /// ```
  static set showRunStatusLogs(bool showRunStatusLogs) {
    OpenAILogger.showRunStatusLogs = showRunStatusLogs;
  }

  /// The constructor of [OpenAI]. It is private, so you can only access the instance by calling the [OpenAI.instance] getter.
  OpenAI._();
}
