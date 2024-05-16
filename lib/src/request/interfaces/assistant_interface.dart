import 'package:flutter_openai/flutter_openai.dart';
import 'package:http/http.dart' as http;

import 'shared_interfaces.dart';

abstract class AssistantInterface
    implements EndpointInterface, ListInterface, RetrieveInterface, DeleteInterface {
  Future<AssistantObject> create(
    String name,
    List<ToolCall> toolCalls, {
    String? description,
    String? instruction,
    List<String>? fileIds,
    http.Client? client,
  });
}
