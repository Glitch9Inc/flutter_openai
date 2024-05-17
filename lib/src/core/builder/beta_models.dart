import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

@immutable
@internal
abstract class BetaModels {
  static const List<Type> betaModels = [
    Assistant,
    Thread,
    Run,
    RunStep,
  ];

  static bool isBetaModel<T>() {
    return betaModels.contains(T.runtimeType);
  }
}
