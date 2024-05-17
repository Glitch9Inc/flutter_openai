import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/string_or_object.dart';
import 'package:flutter_openai/src/core/utils/convert_utils.dart';
import 'package:meta/meta.dart';

export 'response_format.dart';

@immutable
class Assistant {
  final String id;
  final String object;
  final String model;
  final DateTime createdAt;
  final String? name;
  final String? description;
  final String? instructions;
  final List<ToolCall>? tools;
  final Map<String, String>? metadata;
  final double? temperature;
  final double? topP;
  final StringOrObject<ResponseFormat>? responseFormat;

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
      createdAt: ConvertUtils.fromUnix(map['created_at']),
      name: map['name'],
      description: map['description'],
      instructions: map['instructions'],
      model: map['model'],
      tools: map['tools'],
      metadata: map['metadata'],
      temperature: map['temperature'],
      topP: map['top_p'],
      responseFormat: map['response_format'] is String
          ? StringOrObject<ResponseFormat>(string: map['response_format'])
          : StringOrObject<ResponseFormat>(object: ResponseFormat.fromMap(map['response_format'])),
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
      'response_format': responseFormat,
    };
  }
}
