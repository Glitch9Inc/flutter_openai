/// {@template openai_endpoints}
/// The class holding all endpoints for the API that are used.
/// {@endtemplate}
class OpenAIApisEndpoints {
  /// legacy
  //final completion = "/completions";
  //final edits = "/edits";

  final audio = "/audio";
  final chat = "/chat/completions";
  final embeddings = "/embeddings";
  final files = "/files";
  final fineTuning = "/fine_tuning";
  final images = "/images";
  final models = "/models";
  final moderation = "/moderations";
  final assistant = "/assistants";
  final thread = "/threads";

  /// {@macro openai_endpoints}
  static const OpenAIApisEndpoints _instance = OpenAIApisEndpoints._();

  /// {@macro openai_endpoints}
  static OpenAIApisEndpoints get instance => _instance;

  /// {@macro openai_endpoints}
  const OpenAIApisEndpoints._();
}
