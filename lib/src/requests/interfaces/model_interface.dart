import 'package:flutter_openai/src/requests/interfaces/shared_interfaces.dart';

abstract class ModelInterface
    implements EndpointInterface, ListInterface, RetrieveInterface, DeleteInterface {}
