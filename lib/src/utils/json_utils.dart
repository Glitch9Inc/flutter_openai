import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
abstract class JsonUtils {
  static var encoder = JsonEncoder.withIndent('  ');
  static String encode(Map<String, dynamic>? map) {
    return map == null ? '' : encoder.convert(map);
  }

  static Map<String, dynamic>? decode(String? json) {
    return json == null ? null : jsonDecode(json);
  }
}
