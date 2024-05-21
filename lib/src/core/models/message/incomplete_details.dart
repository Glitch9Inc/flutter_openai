class IncompleteDetails {
  final String? reason;
  @override
  int get hashCode => reason.hashCode;

  const IncompleteDetails({required this.reason});
  factory IncompleteDetails.fromMap(Map<String, dynamic> map) {
    return IncompleteDetails(reason: map['reason']);
  }
  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
    };
  }

  @override
  String toString() => 'IncompleteDetails(reason: $reason)';
}
