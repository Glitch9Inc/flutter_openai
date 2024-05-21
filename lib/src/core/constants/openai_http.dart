class OpenAIHttp {
  final get = 'GET';
  final post = 'POST';
  final delete = 'DELETE';

  static const OpenAIHttp _instance = OpenAIHttp._();
  static OpenAIHttp get instance => _instance;
  const OpenAIHttp._();
}
