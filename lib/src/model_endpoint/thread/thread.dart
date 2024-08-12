import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';

class Thread {
  final String id;
  final String object;
  final DateTime createdAt;
  final ToolResources? toolResources;
  final Map<String, String>? metadata;

  const Thread({
    required this.id,
    required this.object,
    required this.createdAt,
    this.toolResources,
    required this.metadata,
  });

  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      id: map.getString('id'),
      object: map.getString('object'),
      createdAt: map.getDateTime('created_at'),
      toolResources: MapSetter.set<ToolResources>(
        map,
        'tool_resources',
        factory: ToolResources.fromMap,
      ),
      metadata: map.getStringMap('metadata'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "object": object,
      "created_at": createdAt.toIso8601String(),
      "tool_resources": toolResources?.toMap(),
      "metadata": metadata,
    };
  }
}
