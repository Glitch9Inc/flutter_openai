import 'package:flutter_openai/src/client/openai_client.dart';
import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

import 'interfaces/fine_tuning_interface.dart';

/// {@template openai_finetunes}
/// This class is responsible for handling all fine-tunes requests, such as creating a fine-tune model.
/// {@endtemplate}
@immutable
@protected
interface class FineTuningService implements FineTuningInterface {
  @override
  String get endpoint => OpenAI.endpoint.fineTuning;

  /// {@macro openai_finetunes}
  FineTuningService() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// [trainingFile] is The ID of an uploaded file that contains training data. The file must be formatted as a JSONL file and uploaded with the purpose of fine-tuning.
  ///
  ///
  /// [validationFile] is the ID of an uploaded file that contains validation data. This data is used to generate validation metrics during fine-tuning.
  ///
  ///
  /// [model] is the name of the base model to fine-tune. The default is "curie" but you can choose from "ada", "babbage", "curie", "davinci", or a fine-tuned model created after 2022-04-21.
  ///
  ///
  /// [nEpoches] is the number of epochs to train the model for. The default is 4.
  ///
  ///
  /// [batchSize] is the batch size to use for training. The default is dynamically configured to be ~0.2% of the number of examples in the training set, capped at 256.
  ///
  ///
  /// [learningRateMultiplier] is the learning rate multiplier to use for training. The default is 0.05, 0.1, or 0.2 depending on the batch size.
  ///
  ///
  /// [promptLossWeight] is the weight to use for loss on the prompt tokens. The default is 0.01.
  ///
  ///
  /// If [computeClassificationMetrics] is set, classification-specific metrics such as accuracy and F-1 score are calculated using the validation set at the end of every epoch.
  ///
  ///
  /// [classificationNClass] is The number of classes in a classification task. This parameter is required for multiclass classification.
  ///
  ///
  /// [classificationPositiveClass] is The positive class in binary classification. This parameter is needed to generate precision, recall, and F1 metrics when doing binary classification.
  ///
  ///
  /// [classificationBetas] is If provided, F-beta scores are calculated at the specified beta values. This is only used for binary classification.
  ///
  ///
  /// [suffix] is A string of up to 40 characters that will be added to the fine-tuned model name.
  ///
  ///
  /// Example:
  /// ```dart
  /// OpenAIFineTuneModel fineTune = await OpenAI.instance.fineTune.create(
  ///  trainingFile: "FILE ID",
  /// );
  ///
  /// print(fineTune.status); // ...
  /// ```
  @override
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
  }) async {
    return await OpenAIClient.post(
      body: {
        "training_file": trainingFile,
        if (validationFile != null) "validation_file": validationFile,
        if (model != null) "model": model,
        if (nEpoches != null) "n_epochs": nEpoches,
        if (batchSize != null) "batch_size": batchSize,
        if (learningRateMultiplier != null) "learning_rate_multiplier": learningRateMultiplier,
        if (promptLossWeight != null) "prompt_loss_weight": promptLossWeight,
        if (computeClassificationMetrics != null)
          "compute_classification_metrics": computeClassificationMetrics,
        if (classificationNClass != null) "classification_n_class": classificationNClass,
        if (classificationPositiveClass != null)
          "classification_positive_class": classificationPositiveClass,
        if (classificationBetas != null) "classification_betas": classificationBetas,
        if (suffix != null) "suffix": suffix,
      },
      to: endpoint,
      create: (Map<String, dynamic> response) {
        return OpenAIFineTuneModel.fromMap(response);
      },
    );
  }

  /// List your organization's fine-tuning jobs.
  ///
  /// Example:
  /// ```dart
  /// List<OpenAIFineTuneModel> fineTunes = await OpenAI.instance.fineTune.list();
  ///
  /// print(fineTunes.first.id);
  /// ```
  @override
  Future<Query<OpenAIFineTuneModel>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) async {
    return await OpenAIRequester.list<OpenAIFineTuneModel>(
      endpoint,
      OpenAIFineTuneModel.fromMap,
    );
  }

  /// This function cancels a fine-tune job by its id.
  ///
  ///
  /// Example:
  /// ```dart
  ///  OpenAIFineTuneModel cancelledFineTune = await OpenAI.instance.fineTune.cancel("FINE TUNE ID");
  ///
  /// print(cancelledFineTune.status); // ...
  /// ```
  @override
  Future<OpenAIFineTuneModel> cancel(String fineTuneId) async {
    final String fineTuneCancelEndpoint = "$endpoint/$fineTuneId/cancel";

    return await OpenAIClient.post(
      to: fineTuneCancelEndpoint,
      create: (Map<String, dynamic> response) {
        return OpenAIFineTuneModel.fromMap(response);
      },
    );
  }

  /// This function deleted a fine-tune job by its id.
  ///
  /// Example:
  /// ```dart
  /// bool deleted = await OpenAI.instance.fineTune.delete("FINE TUNE ID");
  ///
  /// print(deleted); // ...
  /// ```
  @override
  Future<bool> delete(String fineTuneId) async {
    return await ModelService().delete(fineTuneId);
  }

  /// This function lists all events of a fine-tune job by its id.
  ///
  ///
  /// Example:
  /// ```dart
  /// List<OpenAIFineTuneEventModel> events = await OpenAI.instance.fineTune.listEvents("FINE TUNE ID");
  ///
  /// print(events.first.message); // ...
  /// ```
  @override
  Future<List<FineTuningEvent>> listEvents(
    String fineTuneId,
  ) async {
    final String fineTuneEvents = "$endpoint/$fineTuneId/events";

    return await OpenAIClient.get(
      endpoint: fineTuneEvents,
      factory: (Map<String, dynamic> response) {
        final List events = response['data'] as List;

        return events.map((e) => FineTuningEvent.fromMap(e)).toList();
      },
    );
  }

  /// Streams all events of a fine-tune job by its id, as they happen.
  ///
  ///
  /// This is a long-running operation that will not return until the fine-tune job is terminated.
  /// The stream will emit an event every time a new event is available.
  /// The stream will emit an [RequestFailedException] if the fine-tune job is terminated with an error.
  ///
  ///
  /// [fineTuneId] The id of the fine-tune job to stream events for.
  ///
  ///
  /// Example:
  /// ```dart
  /// final eventsStream = OpenAI.instance.fineTune.listEventsStream("FINE TUNE ID");
  ///
  /// eventsStream.listen((event) {
  ///  print(event.message);
  /// });
  ///
  /// ```
  Stream<FineTuningEventChunk> listEventsStream(String fineTuneId) {
    final String fineTuneEvents = "$endpoint/$fineTuneId/events?stream=true";

    return OpenAIClient.getStream<FineTuningEventChunk>(
      from: fineTuneEvents,
      create: (Map<String, dynamic> response) {
        return FineTuningEventChunk.fromMap(response);
      },
    );
  }

  /// This function retrieves a fine-tune job by its id.
  ///
  ///
  /// Example:
  /// ```dart
  /// OpenAIFineTuneModel fineTune = await OpenAI.instance.fineTune.retrieve("FINE TUNE ID");
  ///
  /// print(fineTune.id); // ...
  /// ```
  @override
  Future<OpenAIFineTuneModel> retrieve(String fineTuneId) async {
    final String fineTuneRetrieve = "$endpoint/$fineTuneId";

    return await OpenAIClient.get<OpenAIFineTuneModel>(
      endpoint: fineTuneRetrieve,
      factory: (Map<String, dynamic> response) {
        return OpenAIFineTuneModel.fromMap(response);
      },
    );
  }
}
