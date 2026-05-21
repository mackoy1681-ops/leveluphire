class AssessmentQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  const AssessmentQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

class AssessmentResult {
  final String id;
  final String userId;
  final String topic;
  final int score;
  final int total;
  final DateTime takenAt;

  const AssessmentResult({
    required this.id,
    required this.userId,
    required this.topic,
    required this.score,
    required this.total,
    required this.takenAt,
  });

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    return AssessmentResult(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      topic: map['topic'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      total: map['total'] as int? ?? 0,
      takenAt: DateTime.parse(map['taken_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'topic': topic,
      'score': score,
      'total': total,
      'taken_at': takenAt.toIso8601String(),
    };
  }

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}
