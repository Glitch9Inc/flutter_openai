import 'package:flutter_openai/flutter_openai.dart';

/// Details on the action required to continue the run. Will be null if no action is required.
class RequiredAction {
  /// For now, this is always submit_tool_outputs.
  final String type;

  /// The function definition.
  final SubmitToolOutputs submitToolOutputs;

  const RequiredAction({required this.type, required this.submitToolOutputs});
  factory RequiredAction.fromMap(Map<String, dynamic> map) {
    return RequiredAction(
      type: map['type'],
      submitToolOutputs: SubmitToolOutputs.fromMap(map['submit_tool_outputs']),
    );
  }
}

class SubmitToolOutputs {
  final List<ToolCall> toolCalls;

  const SubmitToolOutputs({required this.toolCalls});
  factory SubmitToolOutputs.fromMap(Map<String, dynamic> map) {
    return SubmitToolOutputs(toolCalls: map['tool_calls']);
  }
}
