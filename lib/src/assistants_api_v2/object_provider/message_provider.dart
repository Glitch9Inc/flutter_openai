import 'dart:io' as io;

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/assistants_api_v2/model/request/message_request.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/model_common/file_purpose.dart';

import '../model/request/upload_request.dart';
import 'base/assistants_api_provider.dart';

class MessageProvider extends AssistantsAPIProvider<Message> {
  MessageProvider(super.api);

  @override
  Future<Result> createInternal() async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a message.");

    MessageRequest? req = api.lastMessageRequest;

    if (req == null) throw ArgumentError("lastRequest must be provided to create a message.");

    List<Attachment> attachments = req.attachments ?? [];

    if (req.hasAttachmentFiles) {
      for (UploadRequest uploadRequest in req.attachmentFiles!) {
        OpenAIFile fileObject =
            await OpenAI.instance.file.upload(file: uploadRequest.file, purpose: uploadRequest.purpose.value);

        attachments.add(Attachment(fileObject.id));
      }
    }

    if (req.hasAttachmentImageUrls) {
      for (String imageUrl in req.attachmentImageUrls!) {
        // download the image and upload it
        if (imageUrl.isEmpty) continue;
        io.File? imageFile = await FileDownloader.downloadFile(imageUrl, "temp_image.jpg");
        if (imageFile == null) {
          logger.severe("Failed to download image from $imageUrl");
          continue;
        }

        OpenAIFile fileObject = await OpenAI.instance.file.upload(file: imageFile, purpose: FilePurpose.vision.value);

        attachments.add(Attachment(fileObject.id));
      }
    }

    Message message = await OpenAI.instance.message.create(
      api.threadId,
      role: ChatRole.user,
      content: req.content,
      attachments: attachments.isEmpty ? null : attachments,
      metadata: req.metadata,
    );

    return Result<Message>.success(message);
  }

  @override
  Future<Result> retrieveInternal(String id) async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a message.");
    if (api.assistantId.isEmpty) throw ArgumentError("assistantId must be provided to create a message.");

    Message message = await OpenAI.instance.message.retrieve(api.threadId);

    return Result<Message>.success(message);
  }

  @override
  Future<Result> deleteInternal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result> listInternal(int count) async {
    if (api.threadId.isEmpty) throw ArgumentError("threadId must be provided to create a message.");

    var result = await OpenAI.instance.message.list(api.threadId, limit: count);
    if (result.data == null) return Result.fail("Failed to list assistants.");
    return Result<List<Message>>.success(result.data!);
  }
}
