import 'package:meta/meta.dart';

/// {@template http_request_failure_exception}
/// This exception is thrown when a request fails, from the API.
/// {@endtemplate}
@immutable
class OpenAIRequestException implements Exception {
  /// The error message of the request that failed, if any.
  final String message;

  /// The status code of the request that failed, if any.
  final int? statusCode;

  final String? solution;

  /// {@macro http_request_failure_exception}
  OpenAIRequestException(this.message, {this.statusCode, this.solution});

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write('OpenAI Request Failed: ');
    sb.write('message: $message, ');
    if (statusCode != null) {
      sb.write('statusCode: $statusCode, ');
    }
    if (solution != null) {
      sb.write('solution: $solution, ');
    }
    return sb.toString();
  }
}
