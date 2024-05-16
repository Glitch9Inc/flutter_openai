import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/request/interfaces/shared_interfaces.dart';

abstract class ModerationInterface implements EndpointInterface {
  Future<ModerationObject> create({
    required String input,
    String? model,
  });
}
