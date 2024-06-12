import 'package:flutter_openai/flutter_openai.dart';

import 'shared_interfaces.dart';

abstract class AssistantInterface
    implements EndpointInterface, ListInterface, RetrieveInterface, DeleteInterface {
  Future<Assistant> create(
    GPTModel model, {
    String? name,
    String? description,
    String? instructions,
    List<ToolCall>? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    ResponseFormat? responseFormat,
  });

  Future<Assistant> modify(
    String assistantId, {
    GPTModel? model,
    String? name,
    String? description,
    String? instruction,
    List? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    ResponseFormat? responseFormat,
  });
}
