class DiagnosticResult {
  final String? resultId;
  final int finalScore;
  final String level;
  final String message;
  final DateTime? createdAt;

  DiagnosticResult({
    required this.resultId,
    required this.finalScore,
    required this.level,
    required this.message,
    this.createdAt,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      resultId: json['resultId']?.toString() ?? json['id']?.toString(),
      finalScore: json['finalScore'] is int ? json['finalScore'] as int : 0,
      level: json['level']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }
}
