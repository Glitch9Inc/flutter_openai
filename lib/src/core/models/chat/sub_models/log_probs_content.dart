import 'top_prob.dart';

class LogProbsContent {
  final String? token;

  final double? logprob;

  final List<int>? bytes;

  final List<TopLogProbsContent>? topLogprobs;

  LogProbsContent({
    this.token,
    this.logprob,
    this.bytes,
    this.topLogprobs,
  });

  factory LogProbsContent.fromMap(
    Map<String, dynamic> map,
  ) {
    return LogProbsContent(
      token: map['token'],
      logprob: map['logprob'],
      bytes: List<int>.from(map['bytes']),
      topLogprobs: List<TopLogProbsContent>.from(
        map['top_logprobs']?.map(
          (x) => TopLogProbsContent.fromMap(x),
        ),
      ),
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
