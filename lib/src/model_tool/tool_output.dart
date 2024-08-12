class ToolOutput {
  final String toolCallId;
  final String output;

  const ToolOutput({required this.toolCallId, required this.output});

  factory ToolOutput.fromMap(Map<String, dynamic> map) {
    return ToolOutput(
      toolCallId: map['tool_call_id'],
      output: map['output'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tool_call_id': toolCallId,
      'output': output,
    };
  }
}
