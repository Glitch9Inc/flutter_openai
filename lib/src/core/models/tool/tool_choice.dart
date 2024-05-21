import 'package:meta/meta.dart';

/// {@template function_call}
/// Controls how the model responds to function calls.
/// {@endtemplate}
@immutable
class ToolChoice {
  /// Force the model to respond to the end-user instead of calling a function.
  static const none = ToolChoice._(type: 'none');

  /// The model can pick between an end-user or calling a function.
  static const auto = ToolChoice._(type: 'auto');

  /// The value of the function call.
  final String type;
  final Map<String, dynamic>? function;

  @override
  int get hashCode => type.hashCode ^ function.hashCode;

  const ToolChoice._({
    required this.type,
    this.function,
  });

  factory ToolChoice.fromString(String value) {
    return ToolChoice._(type: value);
  }

  /// Factory method to create a ToolChoice object from a Map<String, dynamic>.
  factory ToolChoice.fromMap(Map<String, dynamic> map) {
    return ToolChoice._(
      type: map['type'],
      function: map['function'],
    );
  }

  /// Specifying a particular function forces the model to call that function.
  factory ToolChoice.fromFunctionName(String functionName) {
    return ToolChoice._(
      type: 'function',
      function: {'name': functionName},
    );
  }

  toStringOrMap() {
    if (type == 'none') return 'none';
    if (type == 'auto') return 'auto';

    return {'type': type, 'function': function};
  }

  @override
  String toString() {
    return 'ToolChoice(type: $type, function: $function)';
  }

  @override
  bool operator ==(covariant ToolChoice other) {
    if (identical(this, other)) return true;

    return other.type == type && other.function == function;
  }
}
