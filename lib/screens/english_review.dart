import 'package:flutter/material.dart';
import '../models/question_model.dart';

class EnglishReview extends StatelessWidget {
  final List<Map<String, dynamic>> userAnswersList;
  final List<Question> questions;
  final List<Map<String, dynamic>> correctAnswersList;
  final List<String> explanationsList;

  const EnglishReview({
    super.key,
    required this.userAnswersList,
    required this.questions,
    required this.correctAnswersList,
    required this.explanationsList,
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    for (int i = 0; i < userAnswersList.length; i++) {
      if (userAnswersList[i]['isCorrect'] == true) {
        correctCount++;
      }
    }
    final percentage = (correctCount / questions.length * 100).round();
    final passed = percentage >= 76;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Answers',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF5F5F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ENGLISH PROFICIENCY EXAM - ANSWER KEY',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Score: ',
                      ),
                      TextSpan(
                        text: '$correctCount/${questions.length} ($percentage%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' - '),
                      TextSpan(
                        text: passed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          color: passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (passed && percentage >= 76)
                        const TextSpan(
                          text: ' 🎖️ #10',
                          style: TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final userAnswer = userAnswersList[index];
                final question = questions[index];
                final correctAnswer = correctAnswersList[index];
                final explanation = explanationsList[index];
                final isCorrect = userAnswer['isCorrect'] ?? false;
                
                String getAnswerLetter(int? answerIndex) {
                  if (answerIndex == null) return 'No answer';
                  return '${String.fromCharCode(65 + answerIndex)}) ${question.options[answerIndex]}';
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${question.text}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your answer: ',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              getAnswerLetter(userAnswer['userAnswer']),
                              style: TextStyle(
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            const Text(
                              ' ✓',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Correct answer: ',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 13,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${String.fromCharCode(65 + (correctAnswer['correctOptionIndex'] as int))}) ${correctAnswer['correctAnswerText']}',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Explanation: ',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                explanation,
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: const Color(0xFFEEEEEE),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Results',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}