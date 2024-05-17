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
abstract class OpenAIConverter {
  static String fromGPTModel(GPTModel model) {
    return apiEnumMap[model] ?? "unknown";
  }

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
