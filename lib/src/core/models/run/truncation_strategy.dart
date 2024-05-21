import 'package:flutter_openai/src/core/utils/map_setter.dart';

///Controls for how a thread will be truncated prior to the run. Use this to control the intial context window of the run.
class TruncationStrategy {
  ///The truncation strategy to use for the thread. The default is auto. If set to last_messages, the thread will be truncated to the n most recent messages in the thread. When set to auto, messages in the middle of the thread will be dropped to fit the context length of the model, max_prompt_tokens.
  final String? type;

  ///The number of most recent messages from the thread when constructing the context for the run.
  final int? lastMessages;

  const TruncationStrategy({required this.type, this.lastMessages});
  factory TruncationStrategy.fromMap(Map<String, dynamic> map) {
    return TruncationStrategy(
      type: MapSetter.set<String>(map, 'type'),
      lastMessages: MapSetter.set<int>(map, 'last_messages'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'last_messages': lastMessages,
    };
  }

  @override
  String toString() => 'TruncationStrategy(type: $type, lastMessages: $lastMessages)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TruncationStrategy && type == other.type && lastMessages == other.lastMessages;
  }
}
