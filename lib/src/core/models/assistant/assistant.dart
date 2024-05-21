import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/map_setter.dart';
import 'package:meta/meta.dart';

export 'response_format.dart';

@immutable
class Assistant {
  final String id;
  final String object;
  final GPTModel model;
  final DateTime createdAt;
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
      createdAt: MapSetter.setDateTime(map['created_at']),
      name: map['name'],
      description: map['description'],
      instructions: map['instructions'],
      model: MapSetter.setGPTModel(map['model']),
      tools: MapSetter.setList<ToolCall>(
        map,
        'tools',
        factory: (m) => ToolCall.fromMap(m),
      ),
      metadata: MapSetter.setMetadata(map),
      temperature: map['temperature'],
      topP: map['top_p'],
      responseFormat: map['response_format'] is String
          ? ResponseFormat.auto
          : ResponseFormat.fromMap(map['response_format']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'object': object,
      'created_at': createdAt,
      'name': name,
      'description': description,
      'instructions': instructions,
      'model': model,
      'tools': tools,
      'metadata': metadata,
      'temperature': temperature,
      'top_p': topP,
      'response_format': responseFormat?.toMap(),
    };
  }
}
