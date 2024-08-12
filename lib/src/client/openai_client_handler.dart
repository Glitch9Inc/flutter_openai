import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/config/openai_header.dart';
import 'package:flutter_openai/src/config/openai_uri.dart';

import '../flutter_openai_internal.dart';
import 'openai_logging_interceptor.dart';
import 'openai_redirect_interceptor.dart';

class OpenAIClientHandler {
  static final Dio dio = createDio();
  final Logger _logger = Logger("OpenAIClientHandler");

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      connectTimeout: OpenAI.clientSettings.connectTimeout,
      receiveTimeout: OpenAI.clientSettings.receiveTimeout,
      sendTimeout: OpenAI.clientSettings.sendTimeout,
      maxRedirects: OpenAI.clientSettings.maxRedirects,
      followRedirects: true, // 리디렉션 자동 처리'
      validateStatus: (status) {
        if (status == null) return false;
        return status < 400;
      },
    ));

    dio.interceptors.add(OpenAILoggingInterceptor());
    dio.interceptors.add(OpenAIRedirectInterceptor());

    return dio;
  }

  Future<T> performRequest<T>({
    required String endpoint,
    required String method,
    T Function(Map<String, dynamic>)? create,
    Map<String, dynamic>? body,
    bool returnRawResponse = false,
    bool isBeta = false,
  }) async {
    _logger.info("Performing request to $endpoint");
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(isBeta: isBeta);
    Response response;

    try {
      if (method == 'POST') {
        response = await dio.postUri(uri, data: body, options: Options(headers: headers));
      } else if (method == 'GET') {
        response = await dio.getUri(uri, options: Options(headers: headers));
      } else if (method == 'DELETE') {
        response = await dio.deleteUri(uri, options: Options(headers: headers));
      } else {
        throw UnsupportedError('Method $method not supported');
      }

      if (returnRawResponse) {
        return response as T;
      }

      return _parseResponse(create, response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } on OpenAIRequestException catch (e) {
      throw e;
    }
  }

  Future<T> performMultipartRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    required List<MultipartFile> files,
    required Map<String, String> body,
    bool isBeta = false,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(isBeta: isBeta);
    final formData = FormData.fromMap({
      ...body,
      'files': files,
    });

    try {
      final response = await dio.postUri(uri, data: formData, options: Options(headers: headers));
      return _parseResponse(create, response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } on OpenAIRequestException catch (e) {
      throw e;
    }
  }

  Stream<T> postStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    Map<String, dynamic>? body,
    bool isBeta = false,
  }) async* {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(isBeta: isBeta);

    try {
      final response = await dio.postUri(uri,
          data: body,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
          ));
      final stream = response.data!.stream.transform(utf8.decoder).transform(LineSplitter());

      await for (final value in stream.where((event) => event.isNotEmpty)) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        yield create(decoded);
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } on OpenAIRequestException catch (e) {
      throw e;
    }
  }

  Stream<T> getStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    bool isBeta = false,
  }) {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(isBeta: isBeta);

    return dio
        .getUri(uri,
            options: Options(
              headers: headers,
              responseType: ResponseType.stream,
            ))
        .asStream()
        .asyncExpand((response) {
      final stream = response.data!.stream.transform(utf8.decoder).transform(LineSplitter());

      return stream.where((event) => event.isNotEmpty).map((event) {
        final decoded = jsonDecode(event) as Map<String, dynamic>;
        return create(decoded);
      });
    });
  }

  Future<io.File> postAndExpectFileResponse({
    required String endpoint,
    required io.File Function(io.File fileRes) onFileResponse,
    required String outputFileName,
    required io.Directory? outputDirectory,
    Map<String, dynamic>? body,
    bool isBeta = false,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(isBeta: isBeta);

    final filePath = "${outputDirectory?.path ?? ''}/$outputFileName";

    try {
      await dio.downloadUri(uri, filePath, data: body, options: Options(headers: headers));

      final file = io.File(filePath);
      return onFileResponse(file);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } on OpenAIRequestException catch (e) {
      throw e;
    }
  }

  T _parseResponse<T>(T Function(Map<String, dynamic>)? create, Response response) {
    Map<String, dynamic>? decodedBody;

    if (response.data is Map<String, dynamic>) {
      // 이미 파싱된 JSON 데이터인 경우
      decodedBody = response.data as Map<String, dynamic>;
    } else if (response.data is String) {
      // 문자열일 경우 수동으로 파싱
      decodedBody = JsonHttpConverter.decode(response.data);
    } else {
      _logger.severe("Unexpected response data format: ${response.data.runtimeType}");
      throw OpenAIRequestException("Unexpected response data format", statusCode: response.statusCode);
    }

    if (decodedBody == null) {
      _logger.severe("Failed to decode response body: ${response.data}");
      throw OpenAIRequestException("Failed to decode response body", statusCode: response.statusCode);
    }

    if (_isApiError(decodedBody)) {
      final error = decodedBody['error'] as Map<String, dynamic>;
      final message = error['message'] as String;
      final exception = OpenAIRequestException(message, statusCode: response.statusCode);
      throw exception;
    } else {
      return create!(decodedBody);
    }
  }

  bool _isApiError(Map<String, dynamic> decodedResponseBody) {
    return decodedResponseBody.containsKey('error');
  }

  void _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic> && _isApiError(data)) {
      final error = data['error'] as Map<String, dynamic>;
      final message = error['message'] as String;
      throw OpenAIRequestException(message, statusCode: statusCode);
    }

    throw e; // Re-throw other Dio errors
  }
}
