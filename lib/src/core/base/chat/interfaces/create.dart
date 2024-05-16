import 'package:http/http.dart' as http;

import '../../../models/chat/chat_completion.dart';
import '../../../models/tool/tool.dart';
import '../../../sub_models/export.dart';

abstract class CreateInterface {
  Future<ChatCompletion> create({
    required String model,
    required List<Message> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
    Map<String, String>? responseFormat,
    int? seed,
  });

  Stream<ChatCompletionChunk> createStream({
    required String model,
    required List<Message> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    Map<String, String>? responseFormat,
    String? user,
    http.Client? client,
    int? seed,
  });

  Stream<ChatCompletionChunk> createRemoteFunctionStream({
    required String model,
    required List<Message> messages,
    List<OpenAIToolModel>? tools,
    toolChoice,
    double? temperature,
    double? topP,
    int? n,
    stop,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, dynamic>? logitBias,
    String? user,
    http.Client? client,
    Map<String, String>? responseFormat,
    int? seed,
  });
}
