import '../../../models/embedding/embedding.dart';

import 'package:http/http.dart' as http;

abstract class CreateInterface {
  Future<Embedding> create({
    required String model,
    required input,
    String? user,
    http.Client? client,
  });
}
