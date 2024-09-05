import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart' hide File;
import 'package:flutter_openai/src/config/openai_header.dart';
import 'package:flutter_openai/src/config/openai_uri.dart';

import '../flutter_openai_internal.dart';
import 'openai_logging_interceptor.dart';
import 'openai_redirect_interceptor.dart';

class OpenAIClientHandler {
  static final Dio dio = createDio();

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

  final List<CancelToken> _cancelTokens = [];

  Future<T> performRequest<T>({
    required String endpoint,
    required String method,
    T Function(Map<String, dynamic>)? create,
    Map<String, dynamic>? body,
    bool returnRawData = false,
    bool betaApi = false,
    CancelToken? cancelToken,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(betaApi: betaApi);
    Response response;

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      if (method == HttpMethod.post) {
        response = await dio.postUri(uri, data: body, options: Options(headers: headers), cancelToken: dioCancelToken);
      } else if (method == HttpMethod.get) {
        response = await dio.getUri(uri, options: Options(headers: headers), cancelToken: dioCancelToken);
      } else if (method == HttpMethod.delete) {
        response = await dio.deleteUri(uri, options: Options(headers: headers), cancelToken: dioCancelToken);
      } else {
        throw UnsupportedError('Method $method not supported');
      }

      if (returnRawData) return response.data as T;
      return _parseResponse(create, response);
    } catch (e) {
      _handleException(e);
      rethrow;
    } finally {
      _cancelTokens.remove(dioCancelToken);
    }
  }

  Future<T> performMultipartRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    required List<MultipartFile> files,
    required Map<String, String> body,
    bool betaApi = false,
    CancelToken? cancelToken,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(betaApi: betaApi);
    final formData = FormData.fromMap({
      ...body,
      'files': files,
    });

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      final response = await dio.postUri(
        uri,
        data: formData,
        options: Options(headers: headers),
        cancelToken: dioCancelToken,
      );
      return _parseResponse(create, response);
    } catch (e) {
      _handleException(e);
      rethrow;
    } finally {
      _cancelTokens.remove(dioCancelToken);
    }
  }

  Stream<T> postStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    Map<String, dynamic>? body,
    bool betaApi = false,
    CancelToken? cancelToken,
  }) async* {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(betaApi: betaApi);

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      final response = await dio.postUri(uri,
          data: body,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
          ),
          cancelToken: dioCancelToken);
      final stream = response.data!.stream.transform(utf8.decoder).transform(LineSplitter());

      await for (final value in stream.where((event) => event.isNotEmpty)) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        yield create(decoded);
      }
    } catch (e) {
      _handleException(e);
      rethrow;
    } finally {
      _cancelTokens.remove(dioCancelToken);
    }
  }

  Stream<T> getStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    bool betaApi = false,
    CancelToken? cancelToken,
  }) {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(betaApi: betaApi);

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    // Stream 처리
    final streamController = StreamController<T>();

    dio
        .getUri(
          uri,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
          ),
          cancelToken: dioCancelToken,
        )
        .asStream()
        .asyncExpand((response) {
      final stream = response.data!.stream.transform(utf8.decoder).transform(LineSplitter());
      return stream.where((event) => event.isNotEmpty).map((event) {
        final decoded = jsonDecode(event) as Map<String, dynamic>;
        return create(decoded);
      });
    }).listen(
      (data) {
        streamController.add(data);
      },
      onError: (error) {
        streamController.addError(error);
      },
      onDone: () {
        _cancelTokens.remove(dioCancelToken); // 완료 시 토큰 제거
        streamController.close();
      },
      cancelOnError: true,
    );

    return streamController.stream;
  }

  Future<File> postAndExpectFileResponse({
    required String endpoint,
    required File Function(File fileRes) onFileResponse,
    required String outputFileName,
    required Directory? outputDirectory,
    Map<String, dynamic>? body,
    bool betaApi = false,
    CancelToken? cancelToken,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    final headers = OpenAIHeader.build(betaApi: betaApi);
    final filePath = "${outputDirectory?.path ?? ''}/$outputFileName";

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      await dio.downloadUri(
        uri,
        filePath,
        data: body,
        options: Options(headers: headers),
        cancelToken: dioCancelToken,
      );

      final file = File(filePath);
      return onFileResponse(file);
    } catch (e) {
      _handleException(e);
      rethrow;
    } finally {
      _cancelTokens.remove(dioCancelToken);
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
      throw OpenAIRequestException("Unexpected response data format", statusCode: response.statusCode);
    }

    if (decodedBody == null) {
      throw OpenAIRequestException("Failed to decode response body", statusCode: response.statusCode);
    }

    if (decodedBody['object'] == 'error') {
      final message = decodedBody['message'] as String;
      throw OpenAIRequestException(message, statusCode: response.statusCode);
    } else {
      return create!(decodedBody);
    }
  }

  void _handleException(dynamic e) {
    if (e is DioException) {
      _handleDioException(e);
      return;
    } else if (e is OpenAIRequestException) {
      _handleOpenAIRequestException(e);
      return;
    }
    final message = e.toString();
    OpenAI.logger.severe(message);
  }

  void _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.statusMessage;
    OpenAI.logger.severe("DioException [$statusCode]: $message");
  }

  void _handleOpenAIRequestException(OpenAIRequestException e) {
    OpenAI.logger.severe(e.toString());
  }

  void cancelAllRequests() {
    for (final token in _cancelTokens) {
      token.cancel();
    }
    _cancelTokens.clear();
  }
}
