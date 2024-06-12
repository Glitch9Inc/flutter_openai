import 'dart:io';

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/object_providers/base/assistants_api_provider.dart';
import 'package:flutter_openai/src/assistants_api_v2/requests/upload_request.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/models_common/file_purpose.dart';

class MessageProvider extends AssistantsAPIProvider<Message> {
  MessageProvider(super.api, super.logger);

  @override
  Future<Result> createInternal() async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a message.");
    if (api.lastMessageRequest == null)
      throw ArgumentError("lastRequest must be provided to create a message.");

    List<Attachment> attachments = [];

    if (api.lastMessageRequest!.hasAttachmentFiles) {
      for (UploadRequest uploadRequest in api.lastMessageRequest!.attachmentFiles!) {
        OpenAIFile fileObject = await OpenAI.instance.file
            .upload(file: uploadRequest.file, purpose: uploadRequest.purpose.value);

        attachments.add(Attachment(fileObject.id));
      }
    }

    if (api.lastMessageRequest!.hasAttachmentImageUrls) {
      for (String imageUrl in api.lastMessageRequest!.attachmentImageUrls!) {
        // download the image and upload it
        if (imageUrl.isEmpty) continue;
        File? imageFile = await FileDownloader.downloadFile(imageUrl, "temp_image.jpg");
        if (imageFile == null) {
          logger.error("Failed to download image from $imageUrl");
          continue;
        }

        OpenAIFile fileObject =
            await OpenAI.instance.file.upload(file: imageFile, purpose: FilePurpose.vision.value);

        attachments.add(Attachment(fileObject.id));
      }
    }

    Message message = await OpenAI.instance.message.create(
      api.threadId,
      role: ChatRole.user,
      content: api.lastMessageRequest!.content,
      attachments: attachments.isEmpty ? null : attachments,
      metadata: api.lastMessageRequest!.metadata,
    );

    return ResultObject<Message>.success(message);
  }

  @override
  Future<Result> retrieveInternal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result> deleteInternal(String id) {
    throw UnimplementedError();
  }
}
