import 'package:flutter_openai/src/flutter_openai_internal.dart';
import 'package:meta/meta.dart';

import '../client/openai_client.dart';

/// {@template openai_model}
/// The class that handles all the requests related to the models in the OpenAI API.
/// {@endtemplate}
@immutable
@protected
interface class ModelService implements EndpointInterface {
  @override
  String get endpoint => OpenAI.endpoint.models;

  /// Lists all the models available in the OpenAI API and returns a list of [ModelObject] objects.
  /// Refer to [Models](https://platform.openai.com/docs/models/models) for more information about the available models.
  ///
  /// Example:
  /// ```dart
  ///  List<OpenAIModelModel> models = await OpenAI.instance.model.list();
  ///  print(models.first.id);
  /// ```
  Future<Query<ModelObject>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) async {
    return await OpenAIRequester.list<ModelObject>(
      endpoint,
      ModelObject.fromMap,
      limit: limit,
      order: order,
      cursor: cursor,
    );
  }

  /// Retrieves a model by it's id and returns a [ModelObject] object, if the model is not found, it will throw a [OpenAIRequestException].
  ///
  /// [id] is the id of the model to use for this request.
  ///
  /// Example:
  /// ```dart
  /// OpenAIModelModel model = await OpenAI.instance.model.retrieve("text-davinci-003");
  /// print(model.id)
  /// ```
  Future<ModelObject> retrieve(String id) async {
    return await OpenAIClient.get<ModelObject>(
      endpoint: endpoint + '/$id',
      factory: (Map<String, dynamic> response) {
        return ModelObject.fromMap(response);
      },
    );
  }

  /// Deletes a fine-tuned model, returns [true] if the model did been deleted successfully, if the model is not found, it will throw a [OpenAIRequestException].
  ///
  /// [fineTuneId] is the id of the fine-tuned model to delete.
  ///
  /// Example:
  /// ```dart
  /// bool deleted = await OpenAI.instance.fineTune.delete("fine-tune-id");
  /// ```
  Future<bool> delete(String fineTuneId) async {
    final String fineTuneModelDelete = "$endpoint/$fineTuneId";

    return await OpenAIClient.delete(
      endpoint: fineTuneModelDelete,
      factory: (Map<String, dynamic> response) {
        return response['deleted'];
      },
    );
  }
}
