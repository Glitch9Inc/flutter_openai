import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/utils/map_setter.dart';
import 'package:meta/meta.dart';

export 'response_format.dart';

@immutable
class Assistant {
  final String id;
  final String object;
  final GPTModel? model;
  final DateTime? createdAt;
  final String? name;
  final String? description;
  final String? instructions;
  final List<ToolCall>? tools;
  final Map<String, String>? metadata;
  final double? temperature;
  final double? topP;
  final ResponseFormat? responseFormat;

  const Assistant({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.model,
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });

  factory Assistant.fromMap(Map<String, dynamic> map) {
    return Assistant(
      id: map['id'],
      object: map['object'],
      createdAt: MapSetter.set<DateTime>(map, 'created_at'),
      name: MapSetter.set<String>(map, 'name'),
      description: MapSetter.set<String>(map, 'description'),
      instructions: MapSetter.set<String>(map, 'instructions'),
      model: MapSetter.set<GPTModel>(map, 'model'),
      tools: MapSetter.setList<ToolCall>(
        map,
        'tools',
        factory: ToolCall.fromMap,
      ),
      metadata: MapSetter.setMap<String>(map, 'metadata'),
      temperature: MapSetter.set<double>(map, 'temperature'),
      topP: MapSetter.set<double>(map, 'top_p'),
      responseFormat: MapSetter.setStringOr<ResponseFormat>(
        map,
        'response_format',
        stringFactory: ResponseFormat.fromString,
        mapFactory: ResponseFormat.fromMap,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'object': object,
      'created_at': createdAt?.toIso8601String(),
      'name': name,
      'description': description,
      'instructions': instructions,
      'model': model,
      'tools': tools,
      'metadata': metadata,
      'temperature': temperature,
      'top_p': topP,
      'response_format': responseFormat?.toStringOrMap(),
    };
  }
}
