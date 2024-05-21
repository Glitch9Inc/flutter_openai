class AssistantToolResult<T> {
  final String? errorMessage;
  final bool success;
  final List<T>? result;

  const AssistantToolResult({this.result, this.errorMessage, this.success = true});
}
