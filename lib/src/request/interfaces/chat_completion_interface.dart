import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';

abstract class ChatCompletionInterface implements EndpointInterface {
  Future<ChatCompletion> create({
    required String model,
    required List<Message> messages,
    List<FunctionToolCall>? tools,
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
    Map<String, String>? responseFormat,
    int? seed,
  });

  Stream<ChatCompletionChunk> createStream({
    required String model,
    required List<Message> messages,
    List<FunctionToolCall>? tools,
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
    int? seed,
  });

  Stream<ChatCompletionChunk> createRemoteFunctionStream({
    required String model,
    required List<Message> messages,
    List<FunctionToolCall>? tools,
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
    Map<String, String>? responseFormat,
    int? seed,
  });
}
