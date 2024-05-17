import 'dart:io';

import 'package:http/http.dart' as http;

import 'shared_interfaces.dart';

abstract class FileInterface
    implements EndpointInterface, ListInterface, DeleteInterface, RetrieveInterface {
  Future retrieveContent(
    String fileId, {
    http.Client? client,
  });

  Future<FileObject> upload({
    required File file,
    required String purpose,
  });
}
