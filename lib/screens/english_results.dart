// lib/screens/english_results.dart
// ENGLISH PROFICIENCY RESULTS SCREEN
// Shows score, category breakdown, and action buttons

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route_args.dart';
import '../utils/constants.dart';
import '../models/question_model.dart';

class EnglishResults extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int percentage;
  final bool passed;
  final Map<String, int> categoryScores;
  final Map<String, int> categoryTotals;
  final List<Map<String, dynamic>> userAnswersList;
  final List<Question> questions;
  final List<Map<String, dynamic>> correctAnswersList;
  final List<String> explanationsList;

  const EnglishResults({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.categoryScores,
    required this.categoryTotals,
    required this.userAnswersList,
    required this.questions,
    required this.correctAnswersList,
    required this.explanationsList,
  });

  // Category colors (same as exam)
  final Map<String, Color> _categoryColors = const {
    'Grammar': Color(0xFF00E5FF),      // Electric Blue
    'Vocabulary': Color(0xFF00E676),   // Neon Green
    'Reading Comp': Color(0xFFFFD700), // Gold
    'Business English': Color(0xFF9B59B6), // Purple
  };

  // Award icon mapping based on percentage
  String _getAwardIcon() {
    if (percentage >= 96) return '🏆'; // Gold trophy
    if (percentage >= 90) return '🥇'; // Gold medal
    if (percentage >= 80) return '🥈'; // Silver medal
    if (percentage >= 76) return '🎖️'; // Award medal
    return '📘'; // Book for failed
  }

  String _getAwardNumber() {
    if (percentage >= 96) return '#1';
    if (percentage >= 90) return '#3';
    if (percentage >= 80) return '#7';
    if (percentage >= 76) return '#10';
    return '';
  }

  Future<void> _saveAward() async {
    if (passed) {
      final prefs = await SharedPreferences.getInstance();
      final currentAwards = prefs.getStringList('unlocked_awards') ?? [];
      final awardKey = 'award_10_english';
      if (!currentAwards.contains(awardKey)) {
        currentAwards.add(awardKey);
        await prefs.setStringList('unlocked_awards', currentAwards);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Save award when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveAward();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0C10), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      'ENGLISH RESULTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
              ),

              // Scrollable Content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Score Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: passed ? const Color(0xFF00E676) : const Color(0xFFF44336),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Award icon
                            Text(
                              _getAwardIcon(),
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 8),
                            if (passed && _getAwardNumber().isNotEmpty)
                              Text(
                                _getAwardNumber(),
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Percentage
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: passed ? const Color(0xFF00E676) : const Color(0xFFF44336),
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Passed/Failed text
                            Text(
                              passed ? 'PASSED' : 'FAILED',
                              style: TextStyle(
                                color: passed ? const Color(0xFF00E676) : const Color(0xFFF44336),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$score/$totalQuestions correct',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Category breakdown
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SECTION BREAKDOWN',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...categoryScores.entries.map((entry) {
                                final category = entry.key;
                                final score = entry.value;
                                final total = categoryTotals[category] ?? 0;
                                final categoryPercentage = total > 0 ? (score / total * 100).round() : 0;
                                final color = _categoryColors[category] ?? Colors.white;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '$score/$total',
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: total > 0 ? score / total : 0,
                                                backgroundColor: Colors.white24,
                                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                                minHeight: 8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 40,
                                            child: Text(
                                              '$categoryPercentage%',
                                              style: TextStyle(
                                                color: color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons (Fixed at the bottom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              kRouteEnglishExam,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Retake',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              kRouteEnglishReview,
                              arguments: EnglishReviewArgs(
                                userAnswersList: userAnswersList,
                                questions: questions,
                                correctAnswersList: correctAnswersList,
                                explanationsList: explanationsList,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Review\nAnswers',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: const Color(0xFF0B0C10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
}