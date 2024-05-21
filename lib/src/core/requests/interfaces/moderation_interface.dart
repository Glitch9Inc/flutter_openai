import 'package:flutter_openai/src/core/requests/interfaces/shared_interfaces.dart';

abstract class ModerationInterface implements EndpointInterface {
  Future<ModerationObject> create({
    required String input,
    String? model,
  });
}
