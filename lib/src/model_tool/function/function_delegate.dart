import 'dart:convert';

import 'package:flutter_corelib/flutter_corelib.dart';

abstract class FunctionDelegate<TArgument, TResult> {
  final String functionName;
  final TResult defaultResult;

  FunctionDelegate(this.functionName, this.defaultResult);

  Future<Result> executeInternal(String argument) async {
    if (argument.isEmpty) {
      return Result.error("Argument is null or empty.");
    }

    try {
      // Deserialize the argument
      TArgument deserializedArgument = jsonDecode(argument);

      // Execute the function and get the result
      TResult result = await execute(deserializedArgument);

      // Serialize the result and return as success
      return Result<String>.success(jsonEncode(result));
    } catch (e) {
      // Handle any exceptions and return a failure result with the default result serialized
      return Result<String>.error("Failed to handle argument: $e");
    }
  }

  Future<TResult> execute(TArgument argument);
}
