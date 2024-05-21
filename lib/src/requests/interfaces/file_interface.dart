import 'dart:io';

import 'shared_interfaces.dart';

abstract class FileInterface
    implements EndpointInterface, ListInterface, DeleteInterface, RetrieveInterface {
  Future retrieveContent(String fileId);

  Future<FileObject> upload({
    required File file,
    required String purpose,
  });
}
