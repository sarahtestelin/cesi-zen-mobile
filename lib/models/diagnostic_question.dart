class DiagnosticQuestion {
  final String id;
  final String question;
  final int score;
  final bool active;

  DiagnosticQuestion({
    required this.id,
    required this.question,
    required this.score,
    required this.active,
  });

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    return DiagnosticQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      score: json['score'] is int ? json['score'] as int : 0,
      active: json['active'] == true,
    );
  }
}
