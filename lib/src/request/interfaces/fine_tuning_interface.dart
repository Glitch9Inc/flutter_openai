import 'shared_interfaces.dart';

abstract class FineTuningInterface
    implements
        EndpointInterface,
        ListInterface,
        RetrieveInterface,
        CancelInterface,
        DeleteInterface {
  Future<OpenAIFineTuneModel> create({
    required String trainingFile,
    String? validationFile,
    String? model,
    int? nEpoches,
    int? batchSize,
    double? learningRateMultiplier,
    double? promptLossWeight,
    bool? computeClassificationMetrics,
    int? classificationNClass,
    int? classificationPositiveClass,
    int? classificationBetas,
    String? suffix,
  });

  Future<List<FineTuningEvent>> listEvents(String fineTuneId);
  Stream<FineTuningEventChunk> listEventsStream(String fineTuneId);
}
