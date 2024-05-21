/// The last error associated with this run. Will be null if there are no errors.
class RunError {
  /// One of server_error, rate_limit_exceeded, or invalid_prompt.
  final String code;

  /// A human-readable description of the error.
  final String message;

  const RunError({required this.code, required this.message});
  factory RunError.fromMap(Map<String, dynamic> map) {
    return RunError(code: map['code'], message: map['message']);
  }
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }
}
