import 'dart:io';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/model_common/file_purpose.dart';

class UploadRequest {
  final File file;
  final FilePurpose purpose;
  final ToolType target;

  UploadRequest(
    this.file,
    this.purpose,
    this.target,
  );
}
