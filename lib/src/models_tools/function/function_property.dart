/// {@template openai_function_property}
/// This class is used to represent an OpenAI function property.
/// {@endtemplate}
class FunctionProperty {
  static const functionTypeInteger = 'integer';
  static const functionTypeString = 'string';
  static const functionTypeBoolean = 'boolean';
  static const functionTypeNumber = 'number';
  static const functionTypeArray = 'array';
  static const functionTypeObject = 'object';

  final String name;
  final bool isRequired;
  final Map<String, dynamic> _typeMap;

  @override
  int get hashCode {
    return name.hashCode ^ _typeMap.hashCode ^ isRequired.hashCode;
  }

  const FunctionProperty({
    required this.name,
    required Map<String, dynamic> typeMap,
    this.isRequired = false,
  }) : _typeMap = typeMap;

  factory FunctionProperty.primitive({
    required String name,
    String? description,
    bool isRequired = false,
    required String type,
    List? enumValues,
  }) {
    return FunctionProperty(
      name: name,
      isRequired: isRequired,
      typeMap: {
        'type': type,
        if (description != null) 'description': description,
        if (enumValues != null) 'enum': enumValues,
      },
    );
  }

  factory FunctionProperty.string({
    required String name,
    String? description,
    bool isRequired = false,
    List<String>? enumValues,
  }) {
    return FunctionProperty.primitive(
      name: name,
      isRequired: isRequired,
      type: functionTypeString,
      description: description,
      enumValues: enumValues,
    );
  }

  factory FunctionProperty.boolean({
    required String name,
    String? description,
    bool isRequired = false,
  }) {
    return FunctionProperty.primitive(
      name: name,
      isRequired: isRequired,
      type: functionTypeBoolean,
      description: description,
    );
  }

  factory FunctionProperty.integer({
    required String name,
    String? description,
    bool isRequired = false,
  }) {
    return FunctionProperty.primitive(
      name: name,
      isRequired: isRequired,
      type: functionTypeInteger,
      description: description,
    );
  }

  factory FunctionProperty.number({
    required String name,
    String? description,
    bool isRequired = false,
  }) {
    return FunctionProperty.primitive(
      name: name,
      isRequired: isRequired,
      type: functionTypeNumber,
      description: description,
    );
  }

  factory FunctionProperty.array({
    required String name,
    String? description,
    bool isRequired = false,
    required FunctionProperty items,
  }) {
    return FunctionProperty(
      name: name,
      typeMap: {
        'type': functionTypeArray,
        if (description != null) 'description': description,
        'items': items._typeMap,
      },
      isRequired: isRequired,
    );
  }

  factory FunctionProperty.object({
    required String name,
    String? description,
    required Iterable<FunctionProperty> properties,
    bool isRequired = false,
  }) {
    final requiredProperties = properties
        .where((property) => property.isRequired)
        .map((property) => property.name)
        .toList(growable: false);

    return FunctionProperty(
      name: name,
      typeMap: {
        'type': functionTypeObject,
        if (description != null) 'description': description,
        'properties': Map.fromEntries(
          properties.map(
            (property) => property.typeEntry(),
          ),
        ),
        'required': requiredProperties,
      },
      isRequired: isRequired,
    );
  }

  MapEntry<String, Map<String, dynamic>> typeEntry() {
    return MapEntry(name, _typeMap);
  }

  Map<String, dynamic> typeMap() {
    return _typeMap;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      ..._typeMap,
    };
  }
}
