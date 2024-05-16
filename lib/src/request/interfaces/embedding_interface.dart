import 'package:flutter_openai/flutter_openai.dart';

import 'shared_interfaces.dart';

abstract class EmbeddingInterface implements EndpointInterface {
  Future<Embedding> create({
    required String model,
    required input,
    String? user,
  });
}
