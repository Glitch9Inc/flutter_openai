import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

@protected
@immutable
@internal
abstract class MapSetter {
  static T? set<T>(
    Map<String, dynamic> map,
    String fieldName, {
    T Function(Map<String, dynamic>)? factory,
  }) {
    if (_isNull(map, fieldName)) return null;
    var value = map[fieldName];

    try {
      if (T == DateTime) {
        if (value is int) return setDateTime(value) as T;
      } else if (T == GPTModel) {
        if (value is String) return setGPTModel(value) as T;
      } else if (T == ToolType) {
        if (value is String) return setToolType(value) as T;
      } else if (factory != null) {
        if (value is Map<String, dynamic>) {
          if (value.isNotEmpty) return factory(value);
        }
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
    if (map.containsKey(fieldName)) {
      if (map[fieldName] == null) return null;
      if (map[fieldName] is String) return stringFactory(map[fieldName]);
      if (map[fieldName] is Map<String, dynamic>) return mapFactory(map[fieldName]);
    }

    return null;
  }

  static GPTModel setGPTModel(String modelName) {
    for (var key in gptModelMap.keys) {
      if (gptModelMap[key] == modelName) {
        return key;
      }
    }

    return GPTModel.GPT4o;
  }

  static ToolType setToolType(String toolTypeName) {
    for (var key in toolTypeMap.keys) {
      if (toolTypeMap[key] == toolTypeName) {
        return key;
      }
    }

    return ToolType.function;
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

  static List<MessageContent>? setContent(Map<String, dynamic> map) {
    const contentKey = 'content';
    if (_isNull(map, contentKey)) return null;
    var content = map[contentKey];
    if (content is String) {
      return _singleItemListFrom(content);
    } else if (content is List) {
      return _listOfContentItemsFrom(content);
    } else {
      throw Exception(
        'Invalid content type, nor text or list, please report this issue.',
      );
    }
  }

  static List<MessageContent> _singleItemListFrom(String directTextContent) {
    return [
      MessageContent.text(
        directTextContent,
      ),
    ];
  }

  static List<MessageContent> _listOfContentItemsFrom(List listOfContentsItems) {
    return (listOfContentsItems).map(
      (item) {
        if (item is! Map) {
          throw Exception('Invalid content item, please report this issue.');
        } else {
          final asMap = item as Map<String, dynamic>;

          return MessageContent.fromMap(
            asMap,
          );
        }
      },
    ).toList();
  }

  static bool _isNull(Map<String, dynamic> map, String fieldName) {
    return !map.containsKey(fieldName) || map[fieldName] == null;
  }
}
