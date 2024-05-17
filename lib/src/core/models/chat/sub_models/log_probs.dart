// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'log_probs_content.dart';

class LogProbs {
  final List<LogProbsContent> content;
  LogProbs({
    required this.content,
  });

  factory LogProbs.fromMap(
    Map<String, dynamic> json,
  ) {
    return LogProbs(
      content: json["content"] != null
          ? List<LogProbsContent>.from(
              json["content"].map(
                (x) => LogProbsContent.fromMap(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "content": content.map((x) => x.toMap()).toList(),
    };
  }
}
