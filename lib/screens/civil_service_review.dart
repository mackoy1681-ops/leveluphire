import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/question_model.dart';

class CivilServiceReview extends StatelessWidget {
  final List<Question> questions;
  final List<int> userAnswers;
  final List<int> correctAnswers;
  final List<String> explanations;
  final int score;
  final int totalQuestions;

  const CivilServiceReview({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
    required this.explanations,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final passed = percentage >= 80;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Paper color
      appBar: AppBar(
        title: const Text(
          'Review Answers',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header with score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F0),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIVIL SERVICE EXAM - ANSWER KEY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $score/$totalQuestions ($percentage%)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 60,
                  color: passed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ],
            ),
          ),
          // Category Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F0),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Verbal', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Numerical', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Analytical', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('General Info', false),
                ],
              ),
            ),
          ),
          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswer = userAnswers[index];
                final correctAnswer = correctAnswers[index];
                final isCorrect = userAnswer == correctAnswer;
                final explanation = explanations[index];
                
                String category = '';
                // FIXED: changed question.category to question.categoryName
                switch (question.category) {
                  case 'verbal':
                    category = 'Verbal';
                    break;
                  case 'numerical':
                    category = 'Numerical';
                    break;
                  case 'analytical':
                    category = 'Analytical';
                    break;
                  case 'general_info':
                    category = 'General Info';
                    break;
                }
                
                return _buildQuestionItem(
                  number: index + 1,
                  questionText: question.text,
                  userAnswerText: userAnswer >= 0 ? question.options[userAnswer] : 'Not answered',
                  correctAnswerText: question.options[correctAnswer],
                  explanation: explanation,
                  isCorrect: isCorrect,
                  category: category,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: const Color(0xFFF5F5F0),
      selectedColor: const Color(0xFF1A1A1A),
      side: BorderSide(
        color: isSelected ? Colors.transparent : const Color(0xFFCCCCCC),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildQuestionItem({
    required int number,
    required String questionText,
    required String userAnswerText,
    required String correctAnswerText,
    required String explanation,
    required bool isCorrect,
    required String category,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with number and category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$number.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Question text
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // User answer with mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCorrect ? '✓' : '✗',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your answer: $userAnswerText',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCorrect ? const Color(0xFF1A1A1A) : const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          // Correct answer (only shown if wrong)
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Correct answer: $correctAnswerText',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ],
          // Explanation (only shown if wrong)
          if (!isCorrect && explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0E8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      explanation,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Separator line
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
        ],
      ),
    );
  }
}