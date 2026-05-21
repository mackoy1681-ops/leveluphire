class QAPair {
  final String question;
  final String userAnswer;
  final String aiFeedback;

  const QAPair({
    required this.question,
    this.userAnswer = '',
    this.aiFeedback = '',
  });

  Map<String, dynamic> toMap() => {
        'question': question,
        'user_answer': userAnswer,
        'ai_feedback': aiFeedback,
      };

  factory QAPair.fromMap(Map<String, dynamic> map) => QAPair(
        question: map['question'] as String,
        userAnswer: map['user_answer'] as String? ?? '',
        aiFeedback: map['ai_feedback'] as String? ?? '',
      );
}

class InterviewSession {
  final String id;
  final String userId;
  final String field;
  final List<QAPair> history;
  final DateTime completedAt;

  const InterviewSession({
    required this.id,
    required this.userId,
    required this.field,
    this.history = const [],
    required this.completedAt,
  });

  factory InterviewSession.fromMap(Map<String, dynamic> map) {
    final historyRaw = map['history'] as List<dynamic>? ?? [];
    return InterviewSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      field: map['field'] as String? ?? '',
      history: historyRaw
          .map((e) => QAPair.fromMap(e as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'field': field,
        'history': history.map((e) => e.toMap()).toList(),
        'completed_at': completedAt.toIso8601String(),
      };
}
