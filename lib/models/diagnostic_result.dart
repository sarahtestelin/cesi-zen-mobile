class DiagnosticResult {
  final String? resultId;
  final int finalScore;
  final String level;
  final String message;

  DiagnosticResult({
    required this.resultId,
    required this.finalScore,
    required this.level,
    required this.message,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      resultId: json['resultId']?.toString(),
      finalScore: json['finalScore'] is int ? json['finalScore'] as int : 0,
      level: json['level']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
