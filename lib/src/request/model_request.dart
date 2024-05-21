import 'package:flutter_openai/openai.dart';
import 'package:flutter_openai/src/core/models/model/model_object.dart';
import 'package:flutter_openai/src/core/query/query_cursor.dart';
import 'package:flutter_openai/src/core/utils/openai_logger.dart';
import 'package:flutter_openai/src/request/interfaces/model_interface.dart';
import 'package:meta/meta.dart';

import '../core/client/openai_client.dart';

/// {@template openai_model}
/// The class that handles all the requests related to the models in the OpenAI API.
/// {@endtemplate}
@immutable
@protected
interface class ModelRequest implements ModelInterface {
  @override
  String get endpoint => OpenAI.endpoint.models;

  /// {@macro openai_model}
  ModelRequest() {
    OpenAILogger.logEndpoint(endpoint);
  }

  /// Lists all the models available in the OpenAI API and returns a list of [ModelObject] objects.
  /// Refer to [Models](https://platform.openai.com/docs/models/models) for more information about the available models.
  ///
  /// Example:
  /// ```dart
  ///  List<OpenAIModelModel> models = await OpenAI.instance.model.list();
  ///  print(models.first.id);
  /// ```
  @override
  Future<List<ModelObject>> list({
    int limit = DEFAULT_QUERY_LIMIT,
    QueryOrder order = QueryOrder.descending,
    QueryCursor? cursor,
  }) async {
    return await OpenAIClient.get<List<ModelObject>>(
      from: endpoint,
      create: (Map<String, dynamic> response) {
        final List data = response['data'];

        return data.map((model) => ModelObject.fromMap(model)).toList();
      },
    );
  }

  /// Retrieves a model by it's id and returns a [ModelObject] object, if the model is not found, it will throw a [RequestFailedException].
  ///
  /// [id] is the id of the model to use for this request.
  ///
  /// Example:
  /// ```dart
  /// OpenAIModelModel model = await OpenAI.instance.model.retrieve("text-davinci-003");
  /// print(model.id)
  /// ```
  @override
  Future<ModelObject> retrieve(String id) async {
    return await OpenAIClient.get<ModelObject>(
      from: endpoint + '/$id',
      create: (Map<String, dynamic> response) {
        return ModelObject.fromMap(response);
      },
    );
  }

  /// Deletes a fine-tuned model, returns [true] if the model did been deleted successfully, if the model is not found, it will throw a [RequestFailedException].
  ///
  /// [fineTuneId] is the id of the fine-tuned model to delete.
  ///
  /// Example:
  /// ```dart
  /// bool deleted = await OpenAI.instance.fineTune.delete("fine-tune-id");
  /// ```
  @override
  Future<bool> delete(String fineTuneId) async {
    final String fineTuneModelDelete = "$endpoint/$fineTuneId";

    return await OpenAIClient.delete(
      from: fineTuneModelDelete,
      create: (Map<String, dynamic> response) {
        return response['deleted'];
      },
    );
  }
}
