import 'shared_interfaces.dart';

abstract class EmbeddingInterface implements EndpointInterface {
  Future<Embedding> create({
    required String model,
    required input,
    String? user,
  });
}
