import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/utils/map_setter.dart';

class Thread {
  final String id;
  final String object;
  final DateTime createdAt;
  final ToolResource? toolResources;
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
      id: map['id'],
      object: map['object'],
      createdAt: MapSetter.set<DateTime>(map, 'created_at')!,
      toolResources: MapSetter.set<ToolResource>(
        map,
        'tool_resources',
        factory: ToolResource.fromMap,
      ),
      metadata: MapSetter.setMap<String>(map, 'metadata'),
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
