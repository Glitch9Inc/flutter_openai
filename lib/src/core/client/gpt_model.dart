// ignore_for_file: constant_identifier_names

enum GPTModel {
  // GPT-3.5 Turbo models
  /// GPT-3.5 Turbo model with improved instruction following, JSON mode, reproducible outputs,
  /// parallel function calling, and more. Returns a maximum of 4,096 output tokens.
  GPT3_5Turbo1106,

  /// The latest GPT-3.5 Turbo model with higher accuracy at responding in requested formats and
  /// a fix for a bug which caused a text encoding issue for non-English language function calls.
  /// Returns a maximum of 4,096 output tokens.
  GPT3_5Turbo0125,

  // GPT-4 and GPT-4 Turbo models
  /// Snapshot of GPT-4 from June 13th 2023 with improved function calling support.
  /// Returns a maximum of 8,192 output tokens.
  GPT4_0613,

  /// Currently points to GPT-4.
  GPT4,

  /// GPT-4 with the ability to understand images, in addition to all other GPT-4 Turbo capabilities.
  /// This is a preview model version. Returns a maximum of 4,096 output tokens.
  GPT4_1106VisionPreview,

  /// GPT-4 with the ability to understand images, in addition to all other GPT-4 Turbo capabilities.
  /// Returns a maximum of 4,096 output tokens.
  GPT4VisionPreview,

  /// GPT-4 Turbo model featuring improved instruction following, JSON mode, reproducible outputs,
  /// parallel function calling, and more. This is a preview model.
  /// Returns a maximum of 4,096 output tokens.
  GPT4_1106Preview,

  /// Currently points to GPT-4 Turbo Preview.
  GPT4TurboPreview,

  /// The latest GPT-4 Turbo model intended to reduce cases of “laziness” where the model doesn’t complete a task.
  /// Returns a maximum of 4,096 output tokens.
  GPT4_0125Preview,

  // Models Updated on 2024-04-09
  /// GPT-4 Turbo with Vision model. Vision requests can now use JSON mode and function calling.
  /// Returns a maximum of 128,000 tokens.
  GPT4Turbo,

  /// GPT-4 Turbo with Vision model. Vision requests can now use JSON mode and function calling.
  /// Returns a maximum of 128,000 tokens.
  GPT4Turbo20240409,

  // Models Updated on 2024-05-13
  /// Our most advanced, multimodal flagship model that’s cheaper and faster than GPT-4 Turbo.
  /// Currently points to GPT-4o. 128,000 tokens. TRAINING DATA: Up to Oct 2023
  GPT4o,

  /// GPT-4o currently points to this version. 128,000 tokens. TRAINING DATA: Up to Oct 2023
  GPT4o20240513,
}

const apiEnumMap = {
  GPTModel.GPT3_5Turbo1106: "gpt-3.5-turbo-1106",
  GPTModel.GPT3_5Turbo0125: "gpt-3.5-turbo-0125",
  GPTModel.GPT4_0613: "gpt-4-0613",
  GPTModel.GPT4: "gpt-4",
  GPTModel.GPT4_1106VisionPreview: "gpt-4-1106-vision-preview",
  GPTModel.GPT4VisionPreview: "gpt-4-vision-preview",
  GPTModel.GPT4_1106Preview: "gpt-4-1106-preview",
  GPTModel.GPT4TurboPreview: "gpt-4-turbo-preview",
  GPTModel.GPT4_0125Preview: "gpt-4-0125-preview",
  GPTModel.GPT4Turbo: "gpt-4-turbo",
  GPTModel.GPT4Turbo20240409: "gpt-4-turbo-2024-04-09",
  GPTModel.GPT4o: "gpt-4o",
  GPTModel.GPT4o20240513: "gpt-4o-2024-05-13",
};

String getName(GPTModel model) {
  return apiEnumMap[model] ?? "unknown";
}
