import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

const apiEnumMap = {
  GPTModel.GPT3_5Turbo1106: "gpt-3.5-turbo-1106",
  GPTModel.GPT3_5Turbo0125: "gpt-3.5-turbo-0125",
  GPTModel.GPT4_0613: "gpt-4-0613",
  GPTModel.GPT4: "gpt-4",
  GPTModel.GPT4_1106VisionPreview: "gpt-4-1106-vision-preview",
  GPTModel.GPT4VisionPreview: "gpt-4-vision-preview",
  GPTModel.GPT4_1106Preview: "gpt-4-1106-preview",
  GPTModel.GPT4TurboPreview: "gpt-4-turbo-preview",
  GPTModel.GPT4_0125Preview: "gpt-4-0125-preview",
  GPTModel.GPT4Turbo: "gpt-4-turbo",
  GPTModel.GPT4Turbo20240409: "gpt-4-turbo-2024-04-09",
  GPTModel.GPT4o: "gpt-4o",
  GPTModel.GPT4o20240513: "gpt-4o-2024-05-13",
};

@protected
@immutable
@internal
abstract class MapSetter {
  static T? set<T>(
    Map<String, dynamic> map,
    String fieldName, {
    T Function(Map<String, dynamic>)? factory,
  }) {
    if (map.containsKey(fieldName)) {
      // Check if field value is null
      //if (map[fieldName] == Null) return null;
      if (map[fieldName] == null) return null;

      try {
        if (T == DateTime) {
          return setDateTime(map[fieldName] as int) as T;
        } else if (T == GPTModel) {
          return setGPTModel(map[fieldName] as String) as T;
        } else {
          if (factory != null) {
            if (map[fieldName] is Map<String, dynamic> && map[fieldName].isEmpty) return null;

            return factory(map);
          }

          return map[fieldName] as T;
        }
      } catch (e) {
        throw FormatException('Error while parsing field [[[$fieldName]]]: $e');
      }
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

  static String fromGPTModel(GPTModel model) {
    return apiEnumMap[model] ?? "unknown";
  }

  static GPTModel setGPTModel(String modelName) {
    for (var key in apiEnumMap.keys) {
      if (apiEnumMap[key] == modelName) {
        return key;
      }
    }

    return GPTModel.GPT4o;
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
    if (map.containsKey(fieldName)) return defaultValue;
    if (map[fieldName] == null) return defaultValue;

    String stringValue = map[fieldName] as String;

    return enumValues.firstWhere(
      (s) => s.name.toLowerCase() == stringValue.toLowerCase(),
      orElse: () => defaultValue,
    );
  }

  static T? setNullable<T>(value, T Function(Map<String, dynamic>) factory) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      if (value.isEmpty) return null;

      return factory(value);
    }

    return null;
  }

  static List<T>? setList<T>(
    Map<String, dynamic> map,
    String fieldName, {
    required T Function(Map<String, dynamic>) factory,
  }) {
    if (map.containsKey(fieldName)) {
      if (map[fieldName] == null) return null;

      try {
        List listValue = map[fieldName] as List;

        if (listValue.isEmpty) {
          return [];
        }

        return listValue.map((item) => factory(item)).toList();
      } catch (e) {
        throw ArgumentError('Provided value is not a List of Map<String, dynamic>');
      }
    }

    return null;
  }

  static Map<String, T>? setMap<T>(
    Map<String, dynamic> map,
    String fieldName, {
    T Function(Map<String, dynamic>)? factory,
  }) {
    if (_isNull(map, fieldName)) return null;
    var value = map[fieldName];

    try {
      if (value.isEmpty) return {};

      if (T == String) {
        return value.map((key, value) => MapEntry(key, value.toString()));
      }

      if (value is Map<String, dynamic>) {
        if (factory != null) {
          return value.map((key, value) => MapEntry(key, factory(value)));
        }
      }

      return value.map((key, value) => MapEntry(key, value));
    } catch (e) {
      throw FormatException('Error while parsing metadata: $e');
    }
  }

  static List<MessageContent>? setContent(Map<String, dynamic> map) {
    const contentKey = 'content';
    if (map.containsKey(contentKey)) return null;
    if (map[contentKey] == null) return null;
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
    return map.containsKey(fieldName) && map[fieldName] == null;
  }
}
