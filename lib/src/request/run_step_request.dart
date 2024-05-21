import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/request/interfaces/run_step_interface.dart';
import 'package:flutter_openai/src/request/utils/request_utils.dart';
import 'package:http/src/client.dart';

interface class RunStepRequest implements RunStepInterface {
  @override
  String get endpoint => OpenAI.endpoint.runSteps;

  @override
  Future<List<RunStep>> list(String threadId, String runId, {Client? client}) {
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
