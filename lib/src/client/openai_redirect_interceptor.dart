import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/client/openai_client_handler.dart';

import '../flutter_openai_internal.dart';

class OpenAIRedirectInterceptor extends Interceptor {
  final Logger _logger = Logger('DioRedirect');

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    response = await _handleRedirection(response, 'onResponse') ?? response;
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null && err.response!.statusCode == 307) {
      // 307 상태 코드를 처리하여 수동 리디렉션
      Response? response = await _handleRedirection(err.response!, 'onError');
      if (response != null) {
        return handler.resolve(response);
      }
    }

    super.onError(err, handler);
  }

  Future<Response?> _handleRedirection(Response response, String fromMethod) async {
    if (OpenAI.logger.showRedirections) _logger.info('Handling redirection from $fromMethod');

    if (response.statusCode == 307) {
      // 리디렉션할 URL을 Location 헤더에서 추출
      final location = response.headers['location']?.first;
      if (location != null) {
        int redirectCount = response.redirects.length;
        if (OpenAI.logger.showRedirections) {
          _logger.info(
              'Redirecting from ${response.realUri.toString().yellow} to ${location.toString().yellow}. Redirect count: $redirectCount');
        }

        // 새로운 요청을 실행하여 리디렉션을 수동으로 처리
        final newRequestOptions = response.requestOptions.copyWith(path: location);

        // 새로운 요청에서 원래 사용된 Dio 인스턴스를 사용해 헤더와 쿠키를 유지
        try {
          final dioResponse = await OpenAIClientHandler.dio.request(
            location,
            options: Options(
              method: newRequestOptions.method,
              headers: newRequestOptions.headers, // 원래 헤더 유지
            ),
            data: newRequestOptions.data,
          );
          // 새로운 응답을 다음 핸들러에 전달
          return dioResponse;
        } catch (e) {
          _logger.severe('Error during redirection: $e');
        }
      }
    }
    return null;
  }
}
