import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:http/src/client.dart';

interface class RunStepService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.runSteps;

  Future<Query<RunStep>> list(String threadId, String runId,
      {int limit = 20, Client? client}) {
    final formattedEndpoint = endpoint
        .replaceAll("{thread_id}", threadId)
        .replaceAll("{run_id}", runId);

    return OpenAIRequester.list(
        formattedEndpoint,
        limit: limit,
        (p0) => RunStep.fromMap(p0),
        isBeta: true);
  }

  Future<RunStep?> retrieve(String threadId, String runId, String stepId,
      {Client? client}) {
    final formattedEndpoint = endpoint
        .replaceAll("{thread_id}", threadId)
        .replaceAll("{run_id}", runId)
        .replaceAll("{step_id}", stepId);

    return OpenAIRequester.retrieve(
        formattedEndpoint, (p0) => RunStep.fromMap(p0),
        isBeta: true);
  }
}
