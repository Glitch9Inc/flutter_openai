abstract class MapObject<T extends MapObject<T>> {
  MapObject();

  // Abstract method to be implemented by subclasses
  T fromMap(Map<String, dynamic> map);

  Map<String, dynamic> toMap();
}
