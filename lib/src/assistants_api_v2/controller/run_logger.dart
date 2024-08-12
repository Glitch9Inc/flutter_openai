import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_openai/flutter_openai.dart';
import '../../config/openai_strings.dart';

class RunLogger {
  Logger logger = new Logger(OpenAIStrings.openai);

  void log(String message) {
    logger.info(message);
  }

  void warning(String message) {
    logger.warning(message);
  }

  void severe(String errorMessage) {
    logger.severe(errorMessage);
  }

  void runStatus(RunStatus? runStatus) {
    if (OpenAI.logger.showRunStatus) {
      if (runStatus == null) runStatus = RunStatus.unknown;

      log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────");
      log("│ RUN STATUS: $runStatus");
      log("└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────");
    }
  }
}
