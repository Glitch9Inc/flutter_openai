import 'shared_interfaces.dart';

abstract class FileInterface
    implements
        EndpointInterface,
        UploadInterface,
        ListInterface,
        DeleteInterface,
        RetrieveInterface,
        RetrieveContentInterface {}
