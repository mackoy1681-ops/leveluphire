import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';
import '../data/civil_service/verbal_questions.dart';
import '../data/civil_service/numerical_questions.dart';
import '../data/civil_service/analytical_questions.dart';
import '../data/civil_service/general_info_questions.dart';
import '../models/question_model.dart';
import '../models/route_args.dart';

class CivilServiceTestScreen extends StatefulWidget {
  const CivilServiceTestScreen({super.key});

  @override
  State<CivilServiceTestScreen> createState() => _CivilServiceTestScreenState();
}

class _CivilServiceTestScreenState extends State<CivilServiceTestScreen> {
  List<Question> _selectedQuestions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  bool _testCompleted = false;
  int _timeRemaining = 60;
  bool _isTimerRunning = true;
  bool _isAnswered = false;
  String? _profilePhotoUrl;
  bool _isSaving = false;
  
  // Store for review
  List<int> _userAnswersList = [];
  List<int> _correctAnswersList = [];
  List<String> _explanationsList = [];
  List<String> _categoriesList = [];
  
  late Timer _timer;

  // Category names
  final List<String> _categories = ['Verbal', 'Numerical', 'Analytical', 'General Info'];
  
  // Question banks
  List<Question> _allVerbalQuestions = [];
  List<Question> _allNumericalQuestions = [];
  List<Question> _allAnalyticalQuestions = [];
  List<Question> _allGeneralQuestions = [];

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);
  final Color _glowCyan = const Color(0xFF00B4D8);
  final Color _softBlue = const Color(0xFF48CAE4);
  final Color _paperWhite = const Color(0xFFF5F5F5);
  final Color _inkBlack = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadProfilePhoto();
  }

  void _loadQuestions() {
    // Load all questions from banks
    _allVerbalQuestions = List.from(verbalQuestions);
    _allNumericalQuestions = List.from(numericalQuestions);
    _allAnalyticalQuestions = List.from(analyticalQuestions);
    _allGeneralQuestions = List.from(generalInfoQuestions);
    
    _selectRandomQuestions();
    _startTimer();
  }

  void _selectRandomQuestions() {
    // Get medium and hard questions only (skip easy if any)
    final verbalMedium = _allVerbalQuestions.where((q) => q.difficulty == 'medium').toList();
    final verbalHard = _allVerbalQuestions.where((q) => q.difficulty == 'hard').toList();
    final numericalMedium = _allNumericalQuestions.where((q) => q.difficulty == 'medium').toList();
    final numericalHard = _allNumericalQuestions.where((q) => q.difficulty == 'hard').toList();
    final analyticalMedium = _allAnalyticalQuestions.where((q) => q.difficulty == 'medium').toList();
    final analyticalHard = _allAnalyticalQuestions.where((q) => q.difficulty == 'hard').toList();
    final generalMedium = _allGeneralQuestions.where((q) => q.difficulty == 'medium').toList();
    final generalHard = _allGeneralQuestions.where((q) => q.difficulty == 'hard').toList();
    
    verbalMedium.shuffle();
    verbalHard.shuffle();
    numericalMedium.shuffle();
    numericalHard.shuffle();
    analyticalMedium.shuffle();
    analyticalHard.shuffle();
    generalMedium.shuffle();
    generalHard.shuffle();
    
    // Select 5 medium + 5 hard from each category (total 40 questions)
    _selectedQuestions = [
      ...verbalMedium.take(5),
      ...verbalHard.take(5),
      ...numericalMedium.take(5),
      ...numericalHard.take(5),
      ...analyticalMedium.take(5),
      ...analyticalHard.take(5),
      ...generalMedium.take(5),
      ...generalHard.take(5),
    ];
    
    _selectedQuestions.shuffle();
    
    // Initialize tracking lists
    _userAnswersList = List.filled(_selectedQuestions.length, -1);
    _correctAnswersList = List.filled(_selectedQuestions.length, -1);
    _explanationsList = List.filled(_selectedQuestions.length, '');
    _categoriesList = List.filled(_selectedQuestions.length, '');
    
    // Store correct answers and categories
    for (int i = 0; i < _selectedQuestions.length; i++) {
      _correctAnswersList[i] = _selectedQuestions[i].correctOptionIndex;
      _explanationsList[i] = _selectedQuestions[i].explanation ?? '';
      _categoriesList[i] = _selectedQuestions[i].category;
    }
  }

  Future<void> _loadProfilePhoto() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
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
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_timeRemaining > 0 && _isTimerRunning && !_testCompleted) {
          _timeRemaining--;
        } else if (_timeRemaining == 0 && !_testCompleted) {
          _timer.cancel();
          if (!_isAnswered) {
            _finalizeAndMove();
          }
        }
      });
    });
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _finalizeAndMove() {
    if (_isAnswered) return;
    
    setState(() {
      _isAnswered = true;
      _isTimerRunning = false;
      
      if (_selectedOptionIndex != null) {
        _userAnswersList[_currentQuestionIndex] = _selectedOptionIndex!;
        if (_selectedOptionIndex == _selectedQuestions[_currentQuestionIndex].correctOptionIndex) {
          _score++;
        }
      }
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex + 1 < _selectedQuestions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
        _timeRemaining = 60;
        _isTimerRunning = true;
      });
      _timer.cancel();
      _startTimer();
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    _timer.cancel();
    setState(() {
      _testCompleted = true;
      _isTimerRunning = false;
    });
    _autoSaveResult();
  }

  Future<void> _autoSaveResult() async {
    setState(() => _isSaving = true);
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    final percentage = (_score / _selectedQuestions.length * 100).round();
    
    // Calculate per-category scores
    int verbalScore = 0, verbalTotal = 0;
    int numericalScore = 0, numericalTotal = 0;
    int analyticalScore = 0, analyticalTotal = 0;
    int generalScore = 0, generalTotal = 0;
    
    for (int i = 0; i < _selectedQuestions.length; i++) {
      final category = _selectedQuestions[i].category;
      final isCorrect = _userAnswersList[i] == _correctAnswersList[i];
      
      if (category == 'verbal') {
        verbalTotal++;
        if (isCorrect) verbalScore++;
      } else if (category == 'numerical') {
        numericalTotal++;
        if (isCorrect) numericalScore++;
      } else if (category == 'analytical') {
        analyticalTotal++;
        if (isCorrect) analyticalScore++;
      } else if (category == 'general_info') {
        generalTotal++;
        if (isCorrect) generalScore++;
      }
    }
    
    // Store answers as JSON
    final userAnswersJson = jsonEncode(_userAnswersList);
    final correctAnswersJson = jsonEncode(_correctAnswersList);
    final explanationsJson = jsonEncode(_explanationsList);
    
    try {
      final existing = await Supabase.instance.client
          .from('civil_service_results')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        await Supabase.instance.client
            .from('civil_service_results')
            .update({
              'score': _score,
              'total_questions': _selectedQuestions.length,
              'percentage': percentage,
              'verbal_score': verbalScore,
              'numerical_score': numericalScore,
              'analytical_score': analyticalScore,
              'general_info_score': generalScore,
              'user_answers': userAnswersJson,
              'correct_answers': correctAnswersJson,
              'explanations': explanationsJson,
              'taken_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
      } else {
        await Supabase.instance.client.from('civil_service_results').insert({
          'id': const Uuid().v4(),
          'user_id': user.id,
          'score': _score,
          'total_questions': _selectedQuestions.length,
          'percentage': percentage,
          'verbal_score': verbalScore,
          'numerical_score': numericalScore,
          'analytical_score': analyticalScore,
          'general_info_score': generalScore,
          'user_answers': userAnswersJson,
          'correct_answers': correctAnswersJson,
          'explanations': explanationsJson,
          'taken_at': DateTime.now().toIso8601String(),
        });
      }

      // Save award to user_awards (icon #9) - only if score >= 80%
      if (percentage >= 80) {
        final existingAward = await Supabase.instance.client
            .from('user_awards')
            .select()
            .eq('user_id', user.id)
            .eq('test_name', 'Civil Service Exam')
            .maybeSingle();

        if (existingAward == null) {
          await Supabase.instance.client.from('user_awards').insert({
            'id': const Uuid().v4(),
            'user_id': user.id,
            'test_name': 'Civil Service Exam',
            'score': _score,
            'total_questions': _selectedQuestions.length,
            'percentage': percentage,
            'award_level': percentage >= 90 ? 'gold' : 'silver',
            'taken_at': DateTime.now().toIso8601String(),
          });
        } else if (percentage > (existingAward['percentage'] ?? 0)) {
          await Supabase.instance.client
              .from('user_awards')
              .update({
                'score': _score,
                'total_questions': _selectedQuestions.length,
                'percentage': percentage,
                'award_level': percentage >= 90 ? 'gold' : 'silver',
                'taken_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existingAward['id']);
        }
      }
    } catch (e) {
      print('Error saving civil service result: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
      _testCompleted = false;
      _timeRemaining = 60;
      _isTimerRunning = true;
      _userAnswersList = [];
      _correctAnswersList = [];
      _explanationsList = [];
    });
    _selectRandomQuestions();
    _timer.cancel();
    _startTimer();
  }

  void _closeResults() {
    Navigator.pop(context);
  }

  void _openReview() {
    Navigator.pushNamed(
      context,
      kRouteCivilServiceReview,
      arguments: CivilServiceReviewArgs(
        questions: _selectedQuestions,
        userAnswers: _userAnswersList,
        correctAnswers: _correctAnswersList,
        explanations: _explanationsList,
        score: _score,
        totalQuestions: _selectedQuestions.length,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_timeRemaining <= 10) {
      return Colors.red;
    } else if (_timeRemaining <= 20) {
      return Colors.orange;
    }
    return _electricBlue;
  }

  double _getTimerProgress() {
    return _timeRemaining / 60;
  }

  String _getCurrentCategory() {
    if (_selectedQuestions.isEmpty) return '';
    final category = _selectedQuestions[_currentQuestionIndex].category;
    switch (category) {
      case 'verbal': return 'Verbal Ability';
      case 'numerical': return 'Numerical Ability';
      case 'analytical': return 'Analytical Ability';
      case 'general_info': return 'General Information';
      default: return 'Unknown';
    }
  }

  Color _getCategoryColor() {
    final category = _selectedQuestions[_currentQuestionIndex].category;
    switch (category) {
      case 'verbal': return const Color(0xFF00E5FF);      // Cosmic Cyan
      case 'numerical': return const Color(0xFF00FF88);   // Cosmic Green
      case 'analytical': return const Color(0xFFFF9E00);  // Cosmic Orange
      case 'general_info': return const Color(0xFFCC00FF); // Cosmic Purple
      default: return const Color(0xFF00E5FF);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_testCompleted) {
      return _buildResultsScreen();
    }

    if (_selectedQuestions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C10),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }

    final currentQuestion = _selectedQuestions[_currentQuestionIndex];
    final questionProgress = (_currentQuestionIndex + 1) / _selectedQuestions.length;
    final category = _getCurrentCategory();
    final categoryColor = _getCategoryColor();

    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Civil Service Exam', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _timer.cancel();
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: _nebulaBlue,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _deepSpace,
              _nebulaBlue,
            ],
          ),
        ),
        child: Column(
          children: [
            // Warning Banner
            Container(
              margin: const EdgeInsets.fromLTRB(kPadL, kPadL, kPadL, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kError.withOpacity(0.15),
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(color: kError.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ The Civil Service Exam is notoriously difficult with a 40% passing rate. This test uses realistic medium/hard questions. Passing requires 80% or higher.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadL),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: kFontSmall,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_selectedQuestions.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: kFontSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: _getTimerProgress(),
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                            ),
                          ),
                          Text(
                            _formatTime(_timeRemaining),
                            style: TextStyle(
                              color: _getTimerColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadL),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: questionProgress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: _electricBlue,
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question Section (Fixed at top)
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadL, 10, kPadL, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _deepSpace,
                      _nebulaBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: kFontTitle,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Options (Scrollable area)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: kPadL),
                physics: const BouncingScrollPhysics(),
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, idx) {
                  final option = currentQuestion.options[idx];
                  final isSelected = _selectedOptionIndex == idx;
                  return _buildOptionCard(idx, option, isSelected, categoryColor);
                },
              ),
            ),

            // Next Button (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadL, 12, kPadL, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOptionIndex != null ? _finalizeAndMove : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOptionIndex != null ? _electricBlue : Colors.grey,
                    foregroundColor: _deepSpace,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestionIndex + 1 >= _selectedQuestions.length
                            ? 'See Results'
                            : 'Next Question',
                        style: const TextStyle(
                          fontSize: kFontBase,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int idx, String option, bool isSelected, Color categoryColor) {
    return GestureDetector(
      onTap: () => _selectOption(idx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(
            color: isSelected ? categoryColor : categoryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? categoryColor : Colors.white54,
                  width: 1.5,
                ),
                color: isSelected ? categoryColor.withOpacity(0.2) : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx),
                  style: TextStyle(
                    color: isSelected ? categoryColor : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSmall,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? categoryColor : Colors.white,
                  fontSize: kFontBase,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _selectedQuestions.length * 100).round();
    final passed = percentage >= 80;
    
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('CSE Results', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _closeResults,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: _nebulaBlue,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _deepSpace,
              _nebulaBlue,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadL),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Score Circle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: passed ? kSuccess.withOpacity(0.15) : kError.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: passed ? kSuccess : kError,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: passed ? kSuccess : kError,
                      ),
                    ),
                    Text(
                      '$_score/${_selectedQuestions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Pass/Fail Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: passed ? kSuccess.withOpacity(0.2) : kError.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Text(
                  passed ? 'PASSED ✓' : 'FAILED ✗',
                  style: TextStyle(
                    color: passed ? kSuccess : kError,
                    fontSize: kFontSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Scores
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  children: [
                    _buildCategoryScore('Verbal Ability', 'verbal', const Color(0xFF00E5FF)),
                    const SizedBox(height: 12),
                    _buildCategoryScore('Numerical Ability', 'numerical', const Color(0xFF00FF88)),
                    const SizedBox(height: 12),
                    _buildCategoryScore('Analytical Ability', 'analytical', const Color(0xFFFF9E00)),
                    const SizedBox(height: 12),
                    _buildCategoryScore('General Information', 'general_info', const Color(0xFFCC00FF)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetTest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _electricBlue,
                        side: BorderSide(color: _electricBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openReview,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _electricBlue,
                        side: BorderSide(color: _electricBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Review Answers',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _closeResults,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _electricBlue,
                        foregroundColor: _deepSpace,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryScore(String title, String categoryKey, Color color) {
    int score = 0;
    int total = 0;
    
    for (int i = 0; i < _selectedQuestions.length; i++) {
      final category = _selectedQuestions[i].category;
      if (category == categoryKey) {
        total++;
        if (_userAnswersList[i] == _correctAnswersList[i]) {
          score++;
        }
      }
    }
    
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: kFontSmall,
              ),
            ),
            Text(
              '$score/$total ($percentage%)',
              style: TextStyle(
                color: color,
                fontSize: kFontSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: LinearProgressIndicator(
            value: total > 0 ? score / total : 0,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}