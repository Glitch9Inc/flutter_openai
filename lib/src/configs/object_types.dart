class OpenAIObjectTypes {
  final auto = 'auto';
  final jsonObject = 'json_object';
  final codeInterpreter = 'code_interpreter';
  final fileSearch = 'file_search';
  final function = 'function';
  final text = 'text';

  static const OpenAIObjectTypes _instance = OpenAIObjectTypes._();
  static OpenAIObjectTypes get instance => _instance;
  const OpenAIObjectTypes._();
}
