import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';

abstract class AssistantsAPIProvider<T> extends ObjectProvider<T> {
  final AssistantsAPIv2 api;

  AssistantsAPIProvider(this.api) : super();
}
