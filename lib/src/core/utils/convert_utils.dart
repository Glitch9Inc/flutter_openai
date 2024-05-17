import 'package:flutter_openai/flutter_openai.dart';
import 'package:meta/meta.dart';

@protected
@immutable
@internal
abstract class ConvertUtils {
  static DateTime fromUnix(int unixTimestamp) {
    return DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  }

  static RunStatus fromString(String status) {
    return RunStatus.values.firstWhere((s) => s.name.toLowerCase() == status.toLowerCase());
  }

  static List<T>? fromList<T>(value, T Function(Map<String, dynamic>) fromMap) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      return value.map((item) => fromMap(item)).toList();
    }

    throw ArgumentError('Provided value is not a List');
  }

  static List<MessageContent>? fromDynamic(
    fieldData,
  ) {
    if (fieldData == null) return null;
    if (fieldData is String) {
      return _singleItemListFrom(fieldData);
    } else if (fieldData is List) {
      return _listOfContentItemsFrom(fieldData);
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
}
