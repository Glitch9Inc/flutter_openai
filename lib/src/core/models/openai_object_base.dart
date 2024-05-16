import '../sub_models/export.dart';

abstract class OpenAIObjectBase {
  final String? id;
  final String? object;
  final String? model;
  final DateTime? createdAt;
  final DateTime? created;
  final Map<String, String>? metadata;
  final List<Message>? messages;
  final Usage? usage;

  const OpenAIObjectBase({
    this.id,
    this.object,
    this.model,
    this.createdAt,
    this.created,
    this.metadata,
    this.usage,
    this.messages,
  });

  Map<String, dynamic> toMap();
}
