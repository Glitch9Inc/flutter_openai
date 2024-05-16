import 'log_probs_content.dart';

class TopLogProbsContent extends LogProbsContent {
  TopLogProbsContent({
    super.token,
    super.logprob,
    super.bytes,
  });

  factory TopLogProbsContent.fromMap(
    Map<String, dynamic> map,
  ) {
    return TopLogProbsContent(
      token: map['token'],
      logprob: map['logprob'],
      bytes: List<int>.from(map['bytes']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'logprob': logprob,
      'bytes': bytes,
    };
  }
}
