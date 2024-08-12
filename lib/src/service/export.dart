import 'package:meta/meta.dart';

export 'assistant_service.dart';
export 'audio_service.dart';
export 'chat_completion_service.dart';
export 'embedding_service.dart';
export 'file_service.dart';
export 'fine_tuning_service.dart';
export 'image_service.dart';
export 'message_service.dart';
export 'model_service.dart';
export 'moderation_service.dart';
export 'run_service.dart';
export 'run_step_service.dart';
export 'thread_service.dart';

@internal
abstract class EndpointInterface {
  String get endpoint;
}
