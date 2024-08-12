import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

class OpenAILoggingInterceptor extends Interceptor {
  final Logger _logger = Logger('DioLog');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (OpenAI.logger.enabled) _logger.info('Request [${options.method.yellow}] => PATH: ${options.path.yellow}');
    if (OpenAI.logger.showRequestHeaders) _logger.info('Headers: ${options.headers}');
    if (OpenAI.logger.showRequestBody) {
      bool nullOrEmpty = options.data == null || options.data.toString().isEmpty || options.data.toString() == '{}';
      if (nullOrEmpty && !OpenAI.logger.hideEmptyBody) _logger.info('Request Body is null or empty');
      if (!nullOrEmpty) _logger.info('Request Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (OpenAI.logger.enabled)
      _logger
          .info('Response [${response.statusCode.toString().yellow}] => PATH: ${response.requestOptions.path.yellow}');
    if (OpenAI.logger.showResponseBody) {
      bool nullOrEmpty = response.data == null || response.data.toString().isEmpty || response.data.toString() == '{}';
      if (nullOrEmpty && !OpenAI.logger.hideEmptyBody) _logger.info('Response Body is null or empty');
      if (!nullOrEmpty) _logger.info('Response Body: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 403) {
      _logger
          .severe('Error [${err.response?.statusCode.toString().yellow}] => PATH: ${err.requestOptions.path.yellow}');
      _logger.severe('Error Message: ${err.message}');
      _handleStatusCode(err.response?.statusCode);
    }

    super.onError(err, handler);
  }

  void _handleStatusCode(int? statusCode) {
    if (statusCode == null) return;

    _logger.info("Handling status code $statusCode");

    if (statusCode == 400) {
      throw OpenAIRequestException("Bad request", statusCode: statusCode);
    }

    if (statusCode == 401) {
      throw OpenAIRequestException("Invalid Authentication",
          statusCode: statusCode, solution: "Ensure the correct API key and requesting organization are being used.");
    }

    if (statusCode == 403) {
      throw OpenAIRequestException("Country, region, or territory not supported",
          statusCode: statusCode,
          solution: "Please see https://platform.openai.com/docs/supported-countries for more information.");
    }

    if (statusCode == 429) {
      throw OpenAIRequestException("Rate limit reached for requests",
          statusCode: statusCode, solution: "Pace your requests. Read the Rate limit guide.");
    }

    if (statusCode == 500) {
      throw OpenAIRequestException("The server had an error while processing your request",
          statusCode: statusCode,
          solution:
              "Retry your request after a brief wait and contact us if the issue persists. Check the status page.");
    }

    if (statusCode == 503) {
      throw OpenAIRequestException("The engine is currently overloaded, please try again later",
          statusCode: statusCode, solution: "Please retry your requests after a brief wait.");
    }
  }
}
