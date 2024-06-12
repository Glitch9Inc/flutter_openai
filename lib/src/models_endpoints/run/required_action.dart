import 'package:flutter_openai/src/flutter_openai_internal.dart';

/// Details on the action required to continue the run. Will be null if no action is required.
class RequiredAction {
  /// For now, this is always submit_tool_outputs.
  final String? type;

  /// The function definition.
  final SubmitToolOutputs? submitToolOutputs;

  const RequiredAction({required this.type, required this.submitToolOutputs});
  factory RequiredAction.fromMap(Map<String, dynamic> map) {
    return RequiredAction(
      type: MapSetter.set<String>(map, 'type'),
      submitToolOutputs: MapSetter.set<SubmitToolOutputs>(
        map,
        'submit_tool_outputs',
        factory: SubmitToolOutputs.fromMap,
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (type != null) 'type': type,
      if (submitToolOutputs != null) 'submit_tool_outputs': submitToolOutputs?.toMap(),
    };
  }
}

class SubmitToolOutputs {
  final List<ToolCall>? toolCalls;

  const SubmitToolOutputs({required this.toolCalls});
  factory SubmitToolOutputs.fromMap(Map<String, dynamic> map) {
    return SubmitToolOutputs(
      toolCalls: MapSetter.setList<ToolCall>(map, 'tool_calls', factory: ToolCall.fromMap),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (toolCalls != null) 'tool_calls': toolCalls,
    };
  }
}
