/// {@template openai_endpoints}
/// The class holding all endpoints for the API that are used.
/// {@endtemplate}
class OpenAIEndpoints {
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
  final thread = "/threads/{thread_id}";
  final messages = "/threads/{thread_id}/messages";
  final runs = "/threads/{thread_id}/runs";
  final runSteps = "/threads/{thread_id}/runs/{run_id}/steps";

  static const OpenAIEndpoints _instance = OpenAIEndpoints._();
  static OpenAIEndpoints get instance => _instance;
  const OpenAIEndpoints._();
}
