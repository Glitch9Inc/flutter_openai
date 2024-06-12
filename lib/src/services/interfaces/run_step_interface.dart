import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/services/interfaces/shared_interfaces.dart';

abstract class RunStepInterface implements EndpointInterface {
  Future<Query<RunStep>> list(String threadId, String runId);
  Future<RunStep?> retrieve(String threadId, String runId, String stepId);
}
