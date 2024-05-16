import 'dart:io';

import 'package:flutter_openai/src/core/builder/base_api_url.dart';
import 'package:flutter_openai/src/core/client/openai_client.dart';
import 'package:flutter_openai/src/core/models/file/file_object.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../core/constants/strings.dart';
import '../core/utils/logger.dart';
import 'interfaces/file_interface.dart';

/// {@template openai_files}
/// This class is responsible for handling all files requests, such as uploading a file to be used across various endpoints/features.
/// {@endtemplate}
@immutable
@protected
interface class FileRequest implements FileInterface {
  @override
  String get endpoint => OpenAIStrings.endpoints.files;

  /// {@macro openai_files}
  FileRequest() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// This method fetches for your files list that exists in your OPenAI account.
  ///
  /// Example:
  ///```dart
  /// List<OpenAIFileModel> files = await OpenAI.instance.file.list();
  /// print(files.first.id);
  ///```
  @override
  Future<List<FileObject>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
    http.Client? client,
  }) async {
    return await RequestUtils.list<FileObject>(
      endpoint,
      (Map<String, dynamic> map) => FileObject.fromMap(map),
      limit: limit,
      order: order,
      cursor: cursor,
      client: client,
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
  @override
  Future<FileObject> retrieve(
    String fileId, {
    http.Client? client,
  }) async {
    return await RequestUtils.retrieve<FileObject>(
      endpoint,
      (e) => FileObject.fromMap(e),
      fileId,
      client: client,
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
  @override
  Future retrieveContent(
    String fileId, {
    http.Client? client,
  }) async {
    final String fileIdEndpoint = "/$fileId/content";

    return await OpenAIClient.get(
      from: BaseApiUrlBuilder.build(endpoint + fileIdEndpoint),
      returnRawResponse: true,
      client: client,
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
  @override
  Future<FileObject> upload({
    required File file,
    required String purpose,
  }) async {
    return await OpenAIClient.fileUpload(
      to: BaseApiUrlBuilder.build(endpoint),
      body: {
        "purpose": purpose,
      },
      file: file,
      onSuccess: (Map<String, dynamic> response) {
        return FileObject.fromMap(response);
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
  @override
  Future<bool> delete(
    String fileId, {
    http.Client? client,
  }) async {
    return await RequestUtils.delete(endpoint, fileId, client: client);
  }
}
