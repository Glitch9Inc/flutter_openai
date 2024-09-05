extension DynamicMapExt on List<dynamic> {
  List<String> toStringList() {
    return this.cast<String>();
  }

  List<T> toEnumList<T extends Enum>(List<T> values) {
    return this.map((e) => values[e as int]).toList();
  }
}
