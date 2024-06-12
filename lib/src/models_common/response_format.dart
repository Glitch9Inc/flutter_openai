import 'package:meta/meta.dart';

/// {@template function_call}
/// Controls how the model responds to function calls.
/// {@endtemplate}
@immutable
class ResponseFormat {
  /// The model can pick between an end-user or calling a function.
  static const auto = ResponseFormat._(value: 'auto');
  static const json = ResponseFormat._(value: 'json_object');
  static const text = ResponseFormat._(value: 'text');

  /// The value of the function call.
  final value;

  @override
  int get hashCode => value.hashCode;

  /// {@macro function_call}
  const ResponseFormat._({required this.value});

  factory ResponseFormat.fromString(String value) {
    return ResponseFormat._(value: value);
  }

  factory ResponseFormat.fromMap(Map<String, dynamic> map) {
    return ResponseFormat._(value: {'type': map['type']});
  }

  toStringOrMap() {
    if (value == 'auto') return 'auto';

    return {'type': value};
  }

  Map<String, dynamic> toMap() {
    return {'type': value};
  }

  @override
  String toString() => value.toString();

  @override
  bool operator ==(covariant ResponseFormat other) {
    if (identical(this, other)) return true;

    return other.value == value;
  }
}
