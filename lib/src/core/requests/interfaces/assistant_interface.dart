import 'package:flutter_openai/src/core/client/gpt_model.dart';

import 'shared_interfaces.dart';

abstract class AssistantInterface
    implements EndpointInterface, ListInterface, RetrieveInterface, DeleteInterface {
  Future<Assistant> create(
    GPTModel model, {
    String? name,
    String? description,
    String? instructions,
    List<ToolBase>? tools,
    ToolResource? toolResources,
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
    ToolResource? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    ResponseFormat? responseFormat,
  });
}
