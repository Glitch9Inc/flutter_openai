import 'package:meta/meta.dart';

@protected
@immutable
abstract class MapSetter {
  static T? set<T>(
    Map<String, dynamic> map,
    String fieldName, {
    T Function(Map<String, dynamic>)? factory,
    T Function(String)? stringFactory,
  }) {
    if (_isNull(map, fieldName)) return null;
    var value = map[fieldName];

    try {
      if (T == DateTime && value is int) {
        return setDateTime(value) as T;
      } else if (factory != null && value is Map<String, dynamic>) {
        if (value.isNotEmpty) return factory(value);
      } else if (stringFactory != null && value is String) {
        return stringFactory(value);
      } else if (value is T) {
        return value;
      }
    } catch (e) {
      throw FormatException('Error while parsing field [[[$fieldName]]]: $e');
    }

    return null;
  }

  static setStringOr<T>(
    Map<String, dynamic> map,
    String fieldName, {
    required T Function(String) stringFactory,
    required T Function(Map<String, dynamic>) mapFactory,
  }) {
    if (_isNull(map, fieldName)) return null;

    var dynamicValue = map[fieldName];

    if (dynamicValue == null) return null;
    if (dynamicValue is String) return stringFactory(dynamicValue);
    if (dynamicValue is Map<String, dynamic>) return mapFactory(dynamicValue);
    if (dynamicValue is List<Map<String, dynamic>>)
      return dynamicValue.map((item) => mapFactory(item)).toList();

    return null;
  }

  static DateTime setDateTime(int unixTimestamp) {
    return DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  }

  static TEnum setEnum<TEnum extends Enum>(
    Map<String, dynamic> map,
    String fieldName, {
    required List<TEnum> enumValues,
    required TEnum defaultValue,
  }) {
    if (_isNull(map, fieldName)) return defaultValue;

    String stringValue = map[fieldName] as String;
    print('Parsing Enum Value: [[[[[$stringValue]]]]]');

    return enumValues.firstWhere(
      (s) => s.name == stringValue,
      orElse: () => defaultValue,
    );
  }

  static List<T>? setList<T>(
    Map<String, dynamic> map,
    String fieldName, {
    required T Function(Map<String, dynamic>) factory,
  }) {
    if (_isNull(map, fieldName)) return null;
    try {
      if (map[fieldName] is List) {
        List listValue = map[fieldName];

        if (listValue.isEmpty) {
          return [];
        }

        return listValue.map((item) => factory(item)).toList();
      }
    } catch (e) {
      throw FormatException(e.toString());
    }

    return null;
  }

  static Map<String, T>? setMap<T>(
    Map<String, dynamic> map,
    String fieldName, {
    T Function(Map<String, dynamic>)? factory,
  }) {
    if (_isNull(map, fieldName)) return null;
    var mapValue = map[fieldName];

    try {
      if (mapValue.isEmpty) return {};

      if (T == String) {
        return mapValue.map((key, value) => MapEntry(key, value.toString()));
      }

      if (mapValue is Map<String, dynamic>) {
        if (factory != null) {
          return mapValue.map((key, value) => MapEntry(key, factory(value)));
        }
      }

      return mapValue.map((key, value) => MapEntry(key, value));
    } catch (e) {
      throw FormatException('Error while parsing metadata: $e');
    }
  }

  static bool _isNull(Map<String, dynamic> map, String fieldName) {
    return !map.containsKey(fieldName) || map[fieldName] == null;
  }
}
