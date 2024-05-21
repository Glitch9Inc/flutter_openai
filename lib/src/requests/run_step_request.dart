import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:flutter_openai/src/requests/interfaces/run_step_interface.dart';
import 'package:flutter_openai/src/requests/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class RunStepRequest implements RunStepInterface {
  @override
  String get endpoint => OpenAI.endpoint.runSteps;

  @override
  Future<Query<RunStep>> list(String threadId, String runId, {Client? client}) {
    final formattedEndpoint =
        endpoint.replaceAll("{thread_id}", threadId).replaceAll("{run_id}", runId);

    return RequestUtils.list(formattedEndpoint, (p0) => RunStep.fromMap(p0), isBeta: true);
  }

  @override
  Future<RunStep> retrieve(String threadId, String runId, String stepId, {Client? client}) {
    final formattedEndpoint = endpoint
        .replaceAll("{thread_id}", threadId)
        .replaceAll("{run_id}", runId)
        .replaceAll("{step_id}", stepId);

    return RequestUtils.retrieve(formattedEndpoint, (p0) => RunStep.fromMap(p0), isBeta: true);
  }
}
