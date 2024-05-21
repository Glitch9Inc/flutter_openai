import 'package:flutter_openai/src/flutter_openai_internal.dart';

class Query<T> {
  final String? object;
  final List<T>? data;
  final String? firstId;
  final String? lastId;
  final int? hasMore;

  const Query({
    required this.object,
    required this.data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
  });

  factory Query.fromMap(
    Map<String, dynamic> map, {
    required T Function(Map<String, dynamic>) factory,
  }) {
    return Query(
      object: MapSetter.set<String>(map, 'object'),
      data: MapSetter.setList<T>(map, 'data', factory: factory),
      firstId: MapSetter.set<String>(map, 'first_id'),
      lastId: MapSetter.set<String>(map, 'last_id'),
      hasMore: MapSetter.set<int>(map, 'has_more'),
    );
  }
}
