import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/models/run/truncation_strategy.dart';
import 'package:flutter_openai/src/core/models/tool/tool_choice.dart';

class RunOptions {
  final int? maxPromptTokens;
  final int? maxCompletionTokens;
  final TruncationStrategy? truncationStrategy;
  final ToolChoice? toolChoice;
  final ResponseFormat? responseFormat;

  const RunOptions({
    this.maxPromptTokens,
    this.maxCompletionTokens,
    this.truncationStrategy,
    this.toolChoice,
    this.responseFormat,
  });
}
