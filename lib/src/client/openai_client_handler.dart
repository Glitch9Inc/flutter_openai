import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter_openai/src/configs/headers.dart";
import "package:flutter_openai/src/configs/openai_uri.dart";
import "package:http/http.dart" as http;

import "../configs/openai_config.dart";
import "../configs/openai_strings.dart";
import "../flutter_openai_internal.dart";
import "redirection_handling_client.dart";

const openAIChatStreamLineSplitter = const LineSplitter();

class OpenAIClientHandler {
  final http.Client httpClient;
  OpenAIClientHandler({http.Client? client}) : httpClient = client ?? createClient();
  static http.Client createClient() {
    return RedirectHandlingClient(http.Client());
  }

  Future<T> performRequest<T>({
    required String endpoint,
    required String method,
    T Function(Map<String, dynamic>)? create,
    Map<String, dynamic>? body,
    bool returnRawResponse = false,
    bool isBeta = false,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    OpenAILogger.logStartRequest(method, uri.toString());
    final headers = HeadersBuilder.build(isBeta: isBeta);
    http.Response response;

    try {
      if (method == OpenAI.httpMethod.post) {
        response = await httpClient
            .post(uri, headers: headers, body: _encodeBody(body))
            .timeout(OpenAIConfig.requestsTimeOut);
      } else if (method == OpenAI.httpMethod.get) {
        response =
            await httpClient.get(uri, headers: headers).timeout(OpenAIConfig.requestsTimeOut);
      } else if (method == OpenAI.httpMethod.delete) {
        response =
            await httpClient.delete(uri, headers: headers).timeout(OpenAIConfig.requestsTimeOut);
      } else {
        throw UnsupportedError('Method $method not supported');
      }

      _logResponse(uri, response);

      if (returnRawResponse) {
        return response as T;
      }

      return _parseResponse(create, response);
    } catch (e) {
      rethrow;
    }
  }

  Future<T> performMultipartRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    required List<http.MultipartFile> files,
    required Map<String, String> body,
    Map<String, dynamic> Function(String rawResponse)? responseMapAdapter,
    bool isBeta = false,
  }) async {
    final uri = OpenAIUri.parse(endpoint);
    OpenAILogger.logStartRequest(OpenAI.httpMethod.post, uri.toString());
    final headers = HeadersBuilder.build(isBeta: isBeta);
    final request = http.MultipartRequest(OpenAI.httpMethod.post, uri);
    request.headers.addAll(headers);
    request.files.addAll(files);
    request.fields.addAll(body);

    final response = await request.send().timeout(OpenAIConfig.requestsTimeOut);

    OpenAILogger.startingDecoding();
    final encodedBody = await response.stream.bytesToString();
    var decodedBody;

    if (responseMapAdapter == null) {
      if (_tryDecodedToMap(encodedBody)) {
        decodedBody = _decodeToMap(encodedBody);
      } else {
        decodedBody = encodedBody;
      }
    } else {
      decodedBody = responseMapAdapter(encodedBody);
    }

    if (decodedBody is Map<String, dynamic>) {
      if (_doesErrorExists(decodedBody)) {
        final error = decodedBody[OpenAIStrings.errorFieldKey];
        final message = error[OpenAIStrings.messageFieldKey];
        throw RequestFailedException(message, response.statusCode);
      } else {
        return create(decodedBody);
      }
    }

    throw FormatException("Failed to decode JSON: $decodedBody");
  }

  Stream<T> postStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    Map<String, dynamic>? body,
    bool isBeta = false,
  }) async* {
    final uri = OpenAIUri.parse(endpoint);
    final headers = HeadersBuilder.build(isBeta: isBeta);
    OpenAILogger.logStartRequest(OpenAI.httpMethod.post, uri.toString());

    try {
      final request = http.Request(OpenAI.httpMethod.post, uri);
      request.headers.addAll(headers);
      request.body = _encodeBody(body);

      try {
        final respond = await httpClient.send(request);

        try {
          OpenAILogger.startReadStreamResponse();
          final stream =
              respond.stream.transform(utf8.decoder).transform(openAIChatStreamLineSplitter);

          try {
            String respondData = "";
            await for (final value in stream.where((event) => event.isNotEmpty)) {
              final data = value;
              respondData += data;

              final dataLines = data.split("\n").where((element) => element.isNotEmpty).toList();

              for (String line in dataLines) {
                if (line.startsWith(OpenAIStrings.streamResponseStart)) {
                  final String data = line.substring(6);
                  if (data.contains(OpenAIStrings.streamResponseEnd)) {
                    OpenAILogger.streamResponseDone();
                    break;
                  }
                  final decoded = jsonDecode(data) as Map<String, dynamic>;
                  yield create(decoded);
                  continue;
                }

                Map<String, dynamic> decodedData = {};
                try {
                  decodedData = _decodeToMap(respondData);
                } catch (error) {/** ignore, data has not been received */}

                if (_doesErrorExists(decodedData)) {
                  final error = decodedData[OpenAIStrings.errorFieldKey] as Map<String, dynamic>;
                  var message = error[OpenAIStrings.messageFieldKey] as String;
                  message = message.isEmpty ? jsonEncode(error) : message;
                  final statusCode = respond.statusCode;
                  final exception = RequestFailedException(message, statusCode);

                  yield* Stream<T>.error(
                    exception,
                  ); // Error cases sent from openai
                }
              }
            } // end of await for
          } catch (error, stackTrace) {
            yield* Stream<T>.error(
              error,
              stackTrace,
            ); // Error cases in handling stream
          }
        } catch (error, stackTrace) {
          yield* Stream<T>.error(
            error,
            stackTrace,
          ); // Error cases in decoding stream from response
        }
      } catch (e) {
        yield* Stream<T>.error(e); // Error cases in getting response
      }
    } catch (e) {
      yield* Stream<T>.error(e); //Error cases in making request
    }
  }

  Stream<T> getStream<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) create,
    bool isBeta = false,
  }) {
    final controller = StreamController<T>();
    final uri = OpenAIUri.parse(endpoint);
    final httpMethod = OpenAI.httpMethod.get;
    final request = http.Request(httpMethod, uri);
    request.headers.addAll(HeadersBuilder.build(isBeta: isBeta));

    Future<void> close() {
      return Future.wait([
        Future.delayed(Duration.zero, httpClient.close),
        controller.close(),
      ]);
    }

    httpClient.send(request).then((streamedResponse) {
      streamedResponse.stream.listen(
        (value) {
          final data = utf8.decode(value);

          final dataLines = openAIChatStreamLineSplitter
              .convert(data)
              .where((element) => element.isNotEmpty)
              .toList();

          for (String line in dataLines) {
            if (line.startsWith(OpenAIStrings.streamResponseStart)) {
              final String data = line.substring(6);
              if (data.startsWith(OpenAIStrings.streamResponseEnd)) {
                OpenAILogger.streamResponseDone();

                return;
              }

              final decoded = _decodeToMap(data);
              controller.add(create(decoded));
            }
          }
        },
        onDone: () {
          close();
        },
        onError: (err) {
          controller.addError(err);
        },
      );
    });

    return controller.stream;
  }

  Future<File> postAndExpectFileResponse({
    required String endpoint,
    required File Function(File fileRes) onFileResponse,
    required String outputFileName,
    required Directory? outputDirectory,
    Map<String, dynamic>? body,
    bool isBeta = false,
  }) async {
    OpenAILogger.logStartRequest(OpenAI.httpMethod.post, endpoint);

    final uri = OpenAIUri.parse(endpoint);
    final headers = HeadersBuilder.build(isBeta: isBeta);

    final encodedBody = _encodeBody(body);

    final response = await httpClient
        .post(uri, headers: headers, body: encodedBody)
        .timeout(OpenAIConfig.requestsTimeOut);

    OpenAILogger.requestToWithStatusCode(uri, response.statusCode);

    OpenAILogger.startingTryCheckingForError();

    final isJsonDecodedMap = _tryDecodedToMap(response.body);

    if (isJsonDecodedMap) {
      final decodedBody = _decodeToMap(response.body);

      if (_doesErrorExists(decodedBody)) {
        OpenAILogger.errorFoundInRequest();

        final error = decodedBody[OpenAIStrings.errorFieldKey];

        final message = error[OpenAIStrings.messageFieldKey];

        final statusCode = response.statusCode;

        final exception = RequestFailedException(message, statusCode);
        OpenAILogger.errorOcurred(exception);

        throw exception;
      } else {
        OpenAILogger.unexpectedResponseGotten();

        throw OpenAIUnexpectedException(
          "Expected file response, but got non-error json response",
          response.body,
        );
      }
    } else {
      OpenAILogger.noErrorFound();

      OpenAILogger.requestFinishedSuccessfully();

      final fileTypeHeader = "content-type";

      final fileExtensionFromBodyResponseFormat =
          response.headers[fileTypeHeader]?.split("/").last ?? "mp3";

      final fileName = outputFileName + "." + fileExtensionFromBodyResponseFormat;

      File file = File(
        "${outputDirectory != null ? outputDirectory.path : ''}" + "/" + fileName,
      );

      OpenAILogger.creatingFile(fileName);

      await file.create();
      OpenAILogger.fileCreatedSuccessfully(fileName);
      OpenAILogger.writingFileContent(fileName);

      file = await file.writeAsBytes(
        response.bodyBytes,
        mode: FileMode.write,
      );

      OpenAILogger.fileContentWrittenSuccessfully(fileName);

      return onFileResponse(file);
    }
  }

  void _logResponse(Uri uri, http.Response response) {
    OpenAILogger.logResponseBody(response);
    OpenAILogger.requestToWithStatusCode(uri, response.statusCode);
  }

  T _parseResponse<T>(Function(Map<String, dynamic>)? create, http.Response response) {
    if (response.statusCode == HttpStatus.ok) {
      OpenAILogger.startingDecoding();
      Utf8Decoder utf8decoder = Utf8Decoder();
      final convertedBody = utf8decoder.convert(response.bodyBytes);
      final Map<String, dynamic> decodedBody = _decodeToMap(convertedBody);
      OpenAILogger.decodedSuccessfully();

      if (_doesErrorExists(decodedBody)) {
        final Map<String, dynamic> error = decodedBody[OpenAIStrings.errorFieldKey];
        final message = error[OpenAIStrings.messageFieldKey];
        final statusCode = response.statusCode;
        final exception = RequestFailedException(message, statusCode);
        OpenAILogger.errorOcurred(exception);
        throw exception;
      } else {
        OpenAILogger.requestFinishedSuccessfully();

        return _createObject(create, decodedBody);
      }
    } else {
      throw RequestFailedException(
        'Request failed with status: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  static T _createObject<T>(
    Function(Map<String, dynamic>)? factory,
    Map<String, dynamic> decodedBody,
  ) {
    try {
      return factory != null ? factory(decodedBody) : decodedBody;
    } catch (e) {
      throw FormatException('Failed to create [[[$e]]]');
    }
  }

  static String _encodeBody(Map<String, dynamic>? body) {
    String encodedBody = "";
    if (body != null) {
      encodedBody = JsonUtils.encode(body);
    }
    OpenAILogger.logRequestBody(encodedBody);

    return encodedBody;
  }

  static Map<String, dynamic> _decodeToMap(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode JSON: [[[$e]]]');
    }
  }

  static bool _tryDecodedToMap(String responseBody) {
    try {
      jsonDecode(responseBody) as Map<String, dynamic>;

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _doesErrorExists(Map<String, dynamic> decodedResponseBody) {
    return decodedResponseBody[OpenAIStrings.errorFieldKey] != null;
  }
}
