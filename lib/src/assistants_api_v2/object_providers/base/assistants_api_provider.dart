import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';

abstract class AssistantsAPIProvider<T> extends ObjectProvider<T> {
  final AssistantsAPIv2 api;

  AssistantsAPIProvider(this.api, Logger logger) : super(logger);
}
