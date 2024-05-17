import 'package:flutter_openai/src/core/client/gpt_model.dart';
import 'package:http/http.dart' as http;

import 'shared_interfaces.dart';

abstract class AssistantInterface
    implements EndpointInterface, ListInterface, RetrieveInterface, DeleteInterface {
  Future<Assistant> create(
    GPTModel model, {
    String? name,
    String? description,
    String? instruction,
    List<ToolBase>? tools,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    double? temperature,
    double? topP,
    String? responseFormat,
    http.Client? client,
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
    String? responseFormat,
    http.Client? client,
  });
}
