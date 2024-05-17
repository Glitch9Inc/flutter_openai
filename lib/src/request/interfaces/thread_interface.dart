import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';
import 'package:http/http.dart' as http;

abstract class ThreadInterface implements EndpointInterface, RetrieveInterface, DeleteInterface {
  // create and modify
  Future<Thread> create({
    List<Message>? messages,
    ToolResources? toolResources,
    Map<String, String>? metadata,
    http.Client? client,
  });

  Future<Thread> modify(
    String threadId, {
    ToolResources? toolResources,
    Map<String, String>? metadata,
    http.Client? client,
  });
}
