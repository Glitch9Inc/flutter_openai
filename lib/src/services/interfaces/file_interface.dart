import 'dart:io';

import 'package:flutter_openai/flutter_openai.dart';

import 'shared_interfaces.dart';

abstract class FileInterface
    implements EndpointInterface, ListInterface, DeleteInterface, RetrieveInterface {
  Future retrieveContent(String fileId);

  Future<OpenAIFile> upload({
    required File file,
    required String purpose,
  });
}
