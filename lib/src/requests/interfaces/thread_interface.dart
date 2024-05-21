import 'package:flutter_openai/src/requests/interfaces/shared_interfaces.dart';

abstract class ThreadInterface implements EndpointInterface, RetrieveInterface, DeleteInterface {
  // create and modify
  Future<Thread> create({
    List<Message>? messages,
    ToolCall? toolResources,
    Map<String, String>? metadata,
  });

  Future<Thread> modify(
    String threadId, {
    ToolCall? toolResources,
    Map<String, String>? metadata,
  });
}
