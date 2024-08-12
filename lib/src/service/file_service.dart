import 'dart:io';

import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

/// {@template openai_files}
/// This class is responsible for handling all files requests, such as uploading a file to be used across various endpoints/features.
/// {@endtemplate}
@immutable
@protected
interface class FileService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.files;

  /// This method fetches for your files list that exists in your OPenAI account.
  ///
  /// Example:
  ///```dart
  /// List<OpenAIFileModel> files = await OpenAI.instance.file.list();
  /// print(files.first.id);
  ///```
  Future<Query<OpenAIFile>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) async {
    return await OpenAIRequester.list<OpenAIFile>(
      endpoint,
      (Map<String, dynamic> map) => OpenAIFile.fromMap(map),
      limit: limit,
      order: order,
      cursor: cursor,
    );
  }

  /// Fetches for a single file by it's id and returns informations about it.
  ///
  /// Example:
  ///```dart
  /// OpenAIFileModel file = await OpenAI.instance.file.retrieve("FILE ID");
  ///
  /// print(file);
  ///```
  Future<OpenAIFile> retrieve(
    String fileId,
  ) async {
    String formattedEndpoint = "$endpoint/$fileId";

    return await OpenAIRequester.retrieve<OpenAIFile>(
      formattedEndpoint,
      (e) => OpenAIFile.fromMap(e),
    );
  }

  /// Fetches for a single file content by it's id.
  ///
  /// Example:
  /// ```dart
  /// dynamic fileContent  = await OpenAI.instance.file.retrieveContent("FILE ID");
  ///
  /// print(fileContent);
  /// ```
  Future retrieveContent(
    String fileId,
  ) async {
    final String fileIdEndpoint = "/$fileId/content";

    return await OpenAIClient.get(
      endpoint: endpoint + fileIdEndpoint,
      returnRawResponse: true,
    );
  }

  /// Upload a file that contains document(s) to be used across various endpoints/
  /// features. Currently, the size of all the files uploaded by one organization can be
  /// up to 1 GB. Please contact us if you need to increase the storage limit.
  ///
  /// [file] is the `jsonl` file to be uploaded, If the [purpose] is set to "fine-tune", each line is a JSON record with "prompt" and "completion.
  ///
  /// [purpose] Use "fine-tune" for Fine-tuning. This allows us to validate the format of the uploaded file.
  ///
  ///
  /// Example:
  /// ```dart
  /// OpenAIFileModel uploadedFile = await OpenAI.instance.file.upload(
  /// file: File("/* FILE PATH HERE */"),
  /// purpose: "fine-tuning",
  /// );
  /// ```
  Future<OpenAIFile> upload({
    required File file,
    required String purpose,
  }) async {
    return await OpenAIClient.fileUpload(
      to: endpoint,
      body: {
        "purpose": purpose,
      },
      file: file,
      create: (Map<String, dynamic> response) {
        return OpenAIFile.fromMap(response);
      },
    );
  }

  /// This method deleted an existent file from your account used it's id.
  ///
  ///
  /// ```dart
  /// bool isFileDeleted = await OpenAI.instance.file.delete("/* FILE ID */");
  ///
  /// print(isFileDeleted);
  /// ```
  Future<bool> delete(String fileId) async {
    String formattedEndpoint = "$endpoint/$fileId";

    return await OpenAIRequester.delete(formattedEndpoint);
  }
}
