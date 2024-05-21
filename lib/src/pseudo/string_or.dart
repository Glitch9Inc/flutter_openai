class StringOr<T> {
  final String? stringValue;
  final T? objectValue;

  bool get isString => stringValue != null;
  bool get isObject => objectValue != null;

  StringOr.fromString(this.stringValue) : objectValue = null;
  StringOr.fromObject(this.objectValue) : stringValue = null;

  @override
  String toString() {
    if (isString) {
      return 'String: $stringValue';
    } else if (isObject) {
      return 'Object: $objectValue';
    } else {
      return 'None';
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is StringOr<T>) {
      return stringValue == other.stringValue && objectValue == other.objectValue;
    }

    return false;
  }
}
