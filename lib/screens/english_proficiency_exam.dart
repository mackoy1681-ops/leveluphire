// lib/screens/english_proficiency_exam.dart
// ENGLISH PROFICIENCY EXAM - Cosmic Theme
// 30 questions total: Grammar(9), Vocabulary(9), Reading(6), Business(6)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/english_proficiency/grammar_questions.dart';
import '../data/english_proficiency/vocabulary_questions.dart';
import '../data/english_proficiency/reading_questions.dart';
import '../data/english_proficiency/business_questions.dart';
import '../models/question_model.dart';
import '../models/route_args.dart';
import '../utils/constants.dart';

class EnglishProficiencyExam extends ConsumerStatefulWidget {
  const EnglishProficiencyExam({super.key});

  @override
  ConsumerState<EnglishProficiencyExam> createState() => _EnglishProficiencyExamState();
}

class _EnglishProficiencyExamState extends ConsumerState<EnglishProficiencyExam> {
  // Question banks
  late List<Question> _allQuestions;
  late List<Question> _currentExamQuestions;
  
  // Exam state
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  bool _examStarted = false;
  bool _examCompleted = false;
  
  // Timer
  Timer? _timer;
  int _timeRemaining = 0; // 0 = no time limit, but we track for display
  final int _totalTimeSeconds = 45 * 60; // 45 minutes max
  
  // Loading state
  bool _isLoading = true;
  
  // Profile photo url
  String? _profilePhotoUrl;
  
  // Category colors
  final Map<String, Color> _categoryColors = {
    'grammar': const Color(0xFF00E5FF),   // Cosmic Nebula (Electric Blue)
    'vocabulary': const Color(0xFF00E5FF),
    'reading': const Color(0xFF00E5FF),
    'business': const Color(0xFF00E5FF),
  };
  
  // Category display names
  final Map<String, String> _categoryDisplayNames = {
    'grammar': 'Grammar',
    'vocabulary': 'Vocabulary',
    'reading': 'Reading Comp',
    'business': 'Business English',
  };
  
  // Section mapping (which questions belong to which category)
  late List<Map<String, dynamic>> _sections;
  
  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadProfilePhoto();
  }
  
  Future<void> _loadProfilePhoto() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('avatar_url')
            .eq('id', user.id)
            .maybeSingle();
        
        if (response != null && mounted) {
          setState(() {
            _profilePhotoUrl = response['avatar_url'] as String?;
          });
        }
      } catch (e) {
        print('Error loading English exam profile photo: $e');
      }
    }
  }
  
  void _loadQuestions() {
    // Combine all questions from all categories
    _allQuestions = [
      ...grammarQuestions,
      ...vocabularyQuestions,
      ...readingQuestions,
      ...businessQuestions,
    ];
    
    // Randomly select 30 questions (9 Grammar, 9 Vocabulary, 6 Reading, 6 Business)
    _selectExamQuestions();
  }
  
  void _selectExamQuestions() {
    final grammar = List<Question>.from(grammarQuestions)..shuffle();
    final vocabulary = List<Question>.from(vocabularyQuestions)..shuffle();
    final reading = List<Question>.from(readingQuestions)..shuffle();
    final business = List<Question>.from(businessQuestions)..shuffle();
    
    _currentExamQuestions = [
      ...grammar.take(9),
      ...vocabulary.take(9),
      ...reading.take(6),
      ...business.take(6),
    ]..shuffle(); // Shuffle to mix categories
    
    _userAnswers = List.filled(_currentExamQuestions.length, null);
    
    // Build sections for display
    _buildSections();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _buildSections() {
    final Map<String, List<int>> sectionMap = {
      'grammar': [],
      'vocabulary': [],
      'reading': [],
      'business': [],
    };
    
    for (int i = 0; i < _currentExamQuestions.length; i++) {
      final category = _currentExamQuestions[i].category;
      sectionMap[category]?.add(i);
    }
    
    _sections = [];
    int sectionIndex = 1;
    for (final entry in sectionMap.entries) {
      if (entry.value.isNotEmpty) {
        _sections.add({
          'name': entry.key,
          'displayName': _categoryDisplayNames[entry.key]!,
          'color': _categoryColors[entry.key]!,
          'questionIndices': entry.value,
          'sectionNumber': sectionIndex,
          'totalSections': 4,
        });
        sectionIndex++;
      }
    }
  }
  
  String _getCurrentCategory() {
    return _currentExamQuestions[_currentQuestionIndex].category;
  }
  
  String _getCurrentSectionProgress() {
    final category = _getCurrentCategory();
    final section = _sections.firstWhere((s) => s['name'] == category);
    final indices = section['questionIndices'] as List<int>;
    final positionInSection = indices.indexOf(_currentQuestionIndex) + 1;
    return '${section['displayName']} ($positionInSection/${indices.length})';
  }
  
  void _startExam() {
    setState(() {
      _examStarted = true;
      _timeRemaining = _totalTimeSeconds;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        // Time's up - auto submit
        _timer?.cancel();
        _submitExam();
      }
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Color _getTimerColor() {
    if (_timeRemaining > 30) return const Color(0xFF00E5FF); // Electric Blue
    if (_timeRemaining > 10) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
  
  void _selectAnswer(int optionIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _currentExamQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Last question - submit exam
      _submitExam();
    }
  }
  
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  Future<void> _submitExam() async {
    _timer?.cancel();
    
    // Calculate scores
    int correctCount = 0;
    Map<String, int> categoryCorrect = {
      'grammar': 0,
      'vocabulary': 0,
      'reading': 0,
      'business': 0,
    };
    Map<String, int> categoryTotal = {
      'grammar': 0,
      'vocabulary': 0,
      'reading': 0,
      'business': 0,
    };
    
    List<Map<String, dynamic>> userAnswersList = [];
    List<Map<String, dynamic>> correctAnswersList = [];
    List<String> explanationsList = [];
    
    for (int i = 0; i < _currentExamQuestions.length; i++) {
      final q = _currentExamQuestions[i];
      final userAnswer = _userAnswers[i];
      final isCorrect = userAnswer == q.correctOptionIndex;
      
      if (isCorrect) {
        correctCount++;
        categoryCorrect[q.category] = (categoryCorrect[q.category] ?? 0) + 1;
      }
      categoryTotal[q.category] = (categoryTotal[q.category] ?? 0) + 1;
      
      userAnswersList.add({
        'questionId': q.id,
        'questionText': q.text,
        'userAnswer': userAnswer,
        'userAnswerText': userAnswer != null ? q.options[userAnswer] : null,
        'isCorrect': isCorrect,
      });
      
      correctAnswersList.add({
        'questionId': q.id,
        'correctOptionIndex': q.correctOptionIndex,
        'correctAnswerText': q.options[q.correctOptionIndex],
      });
      
      explanationsList.add(q.explanation ?? '');
    }
    
    final percentage = (correctCount / _currentExamQuestions.length * 100).round();
    final passed = percentage >= 76;
    
    // Save to Supabase
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId != null) {
      await supabase.from('english_results').insert({
        'user_id': userId,
        'score': correctCount,
        'total_questions': _currentExamQuestions.length,
        'percentage': percentage,
        'grammar_score': categoryCorrect['grammar'],
        'vocabulary_score': categoryCorrect['vocabulary'],
        'reading_score': categoryCorrect['reading'],
        'business_score': categoryCorrect['business'],
        'user_answers': userAnswersList,
        'correct_answers': correctAnswersList,
        'explanations': explanationsList,
        'taken_at': DateTime.now().toIso8601String(),
      });
    }
    
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        kRouteEnglishResults,
        arguments: EnglishResultsArgs(
          score: correctCount,
          totalQuestions: _currentExamQuestions.length,
          percentage: percentage,
          passed: passed,
          categoryScores: {
            'Grammar': categoryCorrect['grammar'] ?? 0,
            'Vocabulary': categoryCorrect['vocabulary'] ?? 0,
            'Reading Comp': categoryCorrect['reading'] ?? 0,
            'Business English': categoryCorrect['business'] ?? 0,
          },
          categoryTotals: {
            'Grammar': categoryTotal['grammar'] ?? 0,
            'Vocabulary': categoryTotal['vocabulary'] ?? 0,
            'Reading Comp': categoryTotal['reading'] ?? 0,
            'Business English': categoryTotal['business'] ?? 0,
          },
          userAnswersList: userAnswersList,
          questions: _currentExamQuestions,
          correctAnswersList: correctAnswersList,
          explanationsList: explanationsList,
        ),
      );
    }
  }
  

  
  Widget _buildInfoRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0C10),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }
    
    if (!_examStarted) {
      // Show start screen
      return Scaffold(
        backgroundColor: const Color(0xFF0B0C10),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'English Proficiency Exam',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF1F2833),
                backgroundImage: _profilePhotoUrl != null
                    ? CachedNetworkImageProvider(_profilePhotoUrl!)
                    : null,
                child: _profilePhotoUrl == null
                    ? const Icon(Icons.person, size: 18, color: Colors.white54)
                    : null,
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B0C10), Color(0xFF1A1A2E)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'English Proficiency Exam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Measure your English communication skills for BPO and corporate roles',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'This is the same style of English test you\'ll take when applying for BPO, call center, or corporate jobs. Passing requires 76% or higher.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: const Color(0xFF0B0C10),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Active exam screen
    final currentQ = _currentExamQuestions[_currentQuestionIndex];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final currentCategory = _getCurrentCategory();
    final categoryColor = _categoryColors[currentCategory] ?? Colors.white;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'English Proficiency Exam',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1F2833),
              backgroundImage: _profilePhotoUrl != null
                  ? CachedNetworkImageProvider(_profilePhotoUrl!)
                  : null,
              child: _profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white54)
                  : null,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0C10), Color(0xFF1A1A2E)],
          ),
        ),
        child: Column(
          children: [
            // Header with subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'English Proficiency Exam',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Measure your English communication skills for BPO and corporate roles',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Info warning box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF00E5FF), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This is the same style of English test you\'ll take when applying for BPO, call center, or corporate jobs. Passing requires 76% or higher.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category + Question row + Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCurrentSectionProgress(),
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_currentExamQuestions.length}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _getTimerColor(), width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _formatTime(_timeRemaining),
                        style: TextStyle(
                          color: _getTimerColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _currentExamQuestions.length,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                borderRadius: BorderRadius.circular(10),
                minHeight: 4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Question Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: categoryColor.withOpacity(0.5), width: 1.5),
                ),
                child: Text(
                  currentQ.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Option Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: currentQ.options.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedAnswer == index;
                  final letter = String.fromCharCode(65 + index); // A, B, C, D
                  return GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? categoryColor.withOpacity(0.15) : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? categoryColor : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? categoryColor : Colors.transparent,
                              border: Border.all(color: isSelected ? categoryColor : Colors.white54),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${letter}) ${currentQ.options[index]}',
                              style: TextStyle(
                                color: isSelected ? categoryColor : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Previous', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedAnswer != null ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: const Color(0xFF0B0C10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentQuestionIndex == _currentExamQuestions.length - 1
                            ? 'Submit Exam'
                            : 'Next Question →',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}