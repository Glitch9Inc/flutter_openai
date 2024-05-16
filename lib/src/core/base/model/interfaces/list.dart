import "package:http/http.dart" as http;

import '../../../models/model/model_object.dart';

abstract class ListInterface {
  Future<List<ModelObject>> list({
    http.Client? client,
  });
}
