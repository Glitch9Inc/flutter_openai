import 'dart:io';

import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/assistants_api_v2/requests/upload_request.dart';
import 'package:flutter_openai/src/models_common/file_purpose.dart';

class MessageRequest {
  final List<MessageContent> content;
  List<UploadRequest>? attachmentFiles;
  List<String>? attachmentImageUrls;
  Map<String, String>? metadata;

  bool get hasAttachmentFiles => attachmentFiles != null && attachmentFiles!.isNotEmpty;
  bool get hasAttachmentImageUrls => attachmentImageUrls != null && attachmentImageUrls!.isNotEmpty;

  MessageRequest({
    required this.content,
    this.attachmentFiles,
    this.attachmentImageUrls,
    this.metadata,
  });

  MessageRequest.create(String text, {this.metadata}) : content = [MessageContent.text(text)];

  MessageRequest.withFiles(String text, List<File> files, ToolType target, {this.metadata})
      : content = [MessageContent.text(text)],
        attachmentFiles =
            files.map((e) => UploadRequest(e, FilePurpose.assistants, target)).toList();

  MessageRequest.withImageFiles(String text, List<File> files, {this.metadata})
      : content = [MessageContent.text(text)],
        attachmentFiles =
            files.map((e) => UploadRequest(e, FilePurpose.vision, ToolType.unset)).toList();

  MessageRequest.withImageUrls(String text, List<String> imageUrls, {this.metadata})
      : content = [MessageContent.text(text)],
        attachmentImageUrls = imageUrls;
}
