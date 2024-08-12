import "dart:async";
import "dart:io";
import 'package:dio/dio.dart';
import "package:flutter_openai/flutter_openai.dart";
import "package:flutter_openai/src/client/openai_client_handler.dart";
import "package:meta/meta.dart";

@protected
abstract class OpenAIClient {
  static final OpenAIClientHandler defaultInstance = OpenAIClientHandler();

  static Future<T> post<T>({
    required String to,
    required T Function(Map<String, dynamic>) create,
    Map<String, dynamic>? body,
    bool returnRawResponse = false,
    bool isBeta = false,
  }) async {
    return await defaultInstance.performRequest<T>(
      endpoint: to,
      create: create,
      method: OpenAI.httpMethod.post,
      body: body,
      returnRawResponse: returnRawResponse,
      isBeta: isBeta,
    );
  }

  static Future<T> get<T>({
    required String endpoint,
    T Function(Map<String, dynamic>)? factory,
    Map<String, dynamic>? body,
    bool returnRawResponse = false,
    bool isBeta = false,
  }) async {
    return await defaultInstance.performRequest<T>(
      endpoint: endpoint,
      create: factory,
      method: OpenAI.httpMethod.get,
      body: body,
      returnRawResponse: returnRawResponse,
      isBeta: isBeta,
    );
  }

  static Future<T> delete<T>({
    required String endpoint,
    T Function(Map<String, dynamic>)? factory,
    bool isBeta = false,
  }) async {
    return await defaultInstance.performRequest<T>(
      endpoint: endpoint,
      method: OpenAI.httpMethod.delete,
      create: factory,
      isBeta: isBeta,
    );
  }

  static Future<T> postImage<T>({
    required String to,
    required T Function(Map<String, dynamic>) create,
    required File image,
    required Map<String, String> body,
    File? mask,
  }) async {
    final files = [
      await MultipartFile.fromFile(image.path),
      if (mask != null) await MultipartFile.fromFile(mask.path),
    ];

    return defaultInstance.performMultipartRequest<T>(
      endpoint: to,
      create: create,
      files: files,
      body: body,
    );
  }

  static Stream<T> postStream<T>({
    required String to,
    required T Function(Map<String, dynamic>) create,
    required Map<String, dynamic> body,
    bool isBeta = false,
  }) {
    return defaultInstance.postStream<T>(
      endpoint: to,
      create: create,
      body: body,
      isBeta: isBeta,
    );
  }

  static Stream<T> getStream<T>({
    required String from,
    required T Function(Map<String, dynamic>) create,
    bool isBeta = false,
  }) {
    return defaultInstance.getStream<T>(
      endpoint: from,
      create: create,
      isBeta: isBeta,
    );
  }

  static Future<T> fileUpload<T>({
    required String to,
    required T Function(Map<String, dynamic>) create,
    required File file,
    required Map<String, String> body,
    bool isBeta = false,
  }) async {
    final files = [
      await MultipartFile.fromFile(file.path),
    ];

    return defaultInstance.performMultipartRequest<T>(
      endpoint: to,
      create: create,
      files: files,
      body: body,
      isBeta: isBeta,
    );
  }

  static Future<File> postAndExpectFileResponse({
    required String to,
    required File Function(File fileRes) onFileResponse,
    required String outputFileName,
    required Directory? outputDirectory,
    Map<String, dynamic>? body,
    bool isBeta = false,
  }) {
    return defaultInstance.postAndExpectFileResponse(
      endpoint: to,
      onFileResponse: onFileResponse,
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
      body: body,
      isBeta: isBeta,
    );
  }
}
