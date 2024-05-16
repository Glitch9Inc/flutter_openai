import 'package:flutter_openai/src/core/models/model/model_object.dart';
import 'package:http/http.dart' as http;

abstract class RetrieveInterface {
  Future<ModelObject> retrieve(
    String modelId, {
    http.Client? client,
  });
}
