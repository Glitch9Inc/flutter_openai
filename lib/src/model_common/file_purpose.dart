enum FilePurpose { assistants, assistantsOutput, fineTune, fineTuneResults, vision, batchAPI }

extension FilePurposeX on FilePurpose {
  String get value => [
        'assistants',
        'assistants_output',
        'fine-tune',
        'fine-tune-results',
        'vision',
        'batch'
      ][index];
}
