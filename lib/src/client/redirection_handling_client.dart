import 'dart:async';
import 'dart:io';

import 'package:flutter_openai/src/utils/openai_logger.dart';
import 'package:http/http.dart' as http;

class RedirectHandlingClient extends http.BaseClient {
  final http.Client _inner;

  RedirectHandlingClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    http.StreamedResponse response = await _inner.send(request);
    if (response.statusCode == HttpStatus.temporaryRedirect ||
        response.statusCode == HttpStatus.movedTemporarily ||
        response.statusCode == HttpStatus.permanentRedirect) {
      final location = response.headers['location'];
      if (location != null) {
        OpenAILogger.log("Redirecting to $location");

        final newRequest = http.Request(request.method, Uri.parse(location))
          ..headers.addAll(request.headers)
          ..followRedirects = true
          ..maxRedirects = 30;

        if (request is http.Request) {
          newRequest.body = request.body;
        }

        return send(newRequest);
      }
    }

    return response;
  }
}
