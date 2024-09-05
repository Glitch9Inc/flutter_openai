import 'package:flutter_corelib/network/client/client_settings.dart';
import 'package:flutter_openai/src/client/openai_log_settings.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

import 'client/openai_client.dart';
import 'config/openai_header.dart';
import 'config/object_types.dart';
import 'config/openai_config.dart';
import 'config/openai_endpoints.dart';

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
  static OpenAILogSettings logger = OpenAILogSettings();
  static ClientSettings clientSettings = ClientSettings();
  static final endpoint = OpenAIEndpoints.instance;
  static final type = OpenAIObjectTypes.instance;

  /// The singleton instance of [OpenAI].
  static final OpenAI _instance = OpenAI._();

  /// The singleton instance of [OpenAI], make sure to set your OpenAI API key via the [OpenAI.apiKey] setter before accessing the [OpenAI.instance], otherwise it will throw an [Exception].
  /// A [MissingApiKeyException] will be thrown, if the API key is not set.
  static OpenAI get instance {
    // if (_internalApiKey == null) {
    //   throw MissingApiKeyException("""
    //   You must set the api key before accessing the instance of this class.
    //   Example:
    //   OpenAI.apiKey = "Your API Key";
    //   """);
    // }

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
  static String? get organization => OpenAIHeader.organization;

  /// The base API url, by default it is set to the OpenAI API url.
  /// You can change it by calling the [OpenAI.baseUrl] setter.
  static String get baseUrl => OpenAIConfig.baseUrl;

  /// This is used to initialize the [OpenAI] instance, by providing the API key.
  /// All the requests will be authenticated using this API key.
  /// ```dart
  /// OpenAI.apiKey = "YOUR_API_KEY";
  /// ```
  static set apiKey(String apiKey) {
    OpenAIHeader.apiKey = apiKey;
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
    OpenAIHeader.organization = organizationId;
  }

  /// The constructor of [OpenAI]. It is private, so you can only access the instance by calling the [OpenAI.instance] getter.
  OpenAI._();

  void init(
    String apiKey,
    String? organization, {
    OpenAILogSettings? logSettings,
    ClientSettings? clientSettings,
  }) {
    OpenAI.apiKey = apiKey;
    OpenAI.organization = organization;
    if (logSettings != null) OpenAI.logger = logSettings;
    if (clientSettings != null) OpenAI.clientSettings = clientSettings;
  }

  void cancelAllRequests() => OpenAIClient.cancelAllRequests();
}
