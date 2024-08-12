import 'package:meta/meta.dart';

@immutable
final class LastError {
  final String? code;
  final String? message;

  const LastError({
    required this.code,
    required this.message,
  });

  factory LastError.fromMap(Map<String, dynamic> json) {
    return LastError(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }

  @override
  bool operator ==(covariant LastError other) {
    if (identical(this, other)) return true;

    return other.code == code && other.message == message;
  }

  @override
  String toString() => 'LastError(code: $code, message: $message)';
}
