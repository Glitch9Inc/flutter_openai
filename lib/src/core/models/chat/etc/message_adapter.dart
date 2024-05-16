import 'package:flutter_openai/src/core/sub_models/message.dart';

/// This is a mixin class that contains  helper function(s) to adapt old text-based content to the new implementation of the content that accepts a list of content types like images.
mixin class MessageDynamicContentAdapter {
  /// This is a helper function to adapt old text-based content to the new implementation of the content that accepts a list of content types like images..
  static List<ContentItem> dynamicContentFromField(
    fieldData,
  ) {
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

  static List<ContentItem> _singleItemListFrom(String directTextContent) {
    return [
      ContentItem.text(
        directTextContent,
      ),
    ];
  }

  static List<ContentItem> _listOfContentItemsFrom(List listOfContentsItems) {
    return (listOfContentsItems).map(
      (item) {
        if (item is! Map) {
          throw Exception('Invalid content item, please report this issue.');
        } else {
          final asMap = item as Map<String, dynamic>;

          return ContentItem.fromMap(
            asMap,
          );
        }
      },
    ).toList();
  }
}
