import 'dart:convert';

extension StringExtension on String {
  bool get canBeParsedToJson {
    try {
      final _ = jsonDecode(this);

      return true;
    } catch (e) {
      return false;
    }
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }
}
