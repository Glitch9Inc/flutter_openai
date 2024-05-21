import 'package:flutter_openai/src/core/requests/interfaces/shared_interfaces.dart';

abstract class ThreadInterface implements EndpointInterface, RetrieveInterface, DeleteInterface {
  // create and modify
  Future<Thread> create({
    List<Message>? messages,
    ToolBase? toolResources,
    Map<String, String>? metadata,
  });

  Future<Thread> modify(
    String threadId, {
    ToolBase? toolResources,
    Map<String, String>? metadata,
  });
}
