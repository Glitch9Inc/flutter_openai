import '../flutter_openai_internal.dart';

class IncompleteDetails {
  final String? reason;

  @override
  int get hashCode => reason.hashCode;

  const IncompleteDetails({required this.reason});

  factory IncompleteDetails.fromMap(Map<String, dynamic> map) {
    return IncompleteDetails(reason: MapSetter.set<String>(map, 'reason'));
  }

  Map<String, dynamic> toMap() {
    return {
      if (reason != null) 'reason': reason,
    };
  }

  @override
  String toString() => 'IncompleteDetails(reason: $reason)';
}
