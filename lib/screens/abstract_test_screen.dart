import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/abstract_reasoning_questions.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';

class AbstractTestScreen extends ConsumerStatefulWidget {
  const AbstractTestScreen({super.key});

  @override
  ConsumerState<AbstractTestScreen> createState() => _AbstractTestScreenState();
}

class _AbstractTestScreenState extends ConsumerState<AbstractTestScreen> {
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
  
  late Timer _timer;

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);
  final Color _glowCyan = const Color(0xFF00B4D8);
  final Color _softBlue = const Color(0xFF48CAE4);

  @override
  void initState() {
    super.initState();
    _selectRandomQuestions();
    _startTimer();
    _loadProfilePhoto();
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

  void _selectRandomQuestions() {
    final easyQuestions = abstractReasoningQuestions
        .where((q) => q.difficulty == 'easy')
        .toList();
    final mediumQuestions = abstractReasoningQuestions
        .where((q) => q.difficulty == 'medium')
        .toList();
    
    easyQuestions.shuffle();
    mediumQuestions.shuffle();
    
    _selectedQuestions = [
      ...easyQuestions.take(10),
      ...mediumQuestions.take(10),
    ];
    
    _selectedQuestions.shuffle();
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
    
    // Only save if score is 75% or higher
    if (percentage >= 75) {
      final awardLevel = percentage >= 80 ? 'gold' : 'silver';

      try {
        final existing = await Supabase.instance.client
            .from('user_awards')
            .select()
            .eq('user_id', user.id)
            .eq('test_name', 'Abstract Reasoning')
            .maybeSingle();

        // Only save if no existing record OR new score is higher
        if (existing == null || percentage > (existing['percentage'] ?? 0)) {
          if (existing != null) {
            await Supabase.instance.client
                .from('user_awards')
                .update({
                  'score': _score,
                  'total_questions': _selectedQuestions.length,
                  'percentage': percentage,
                  'award_level': awardLevel,
                  'taken_at': DateTime.now().toIso8601String(),
                })
                .eq('id', existing['id']);
          } else {
            await Supabase.instance.client.from('user_awards').insert({
              'id': const Uuid().v4(),
              'user_id': user.id,
              'test_name': 'Abstract Reasoning',
              'score': _score,
              'total_questions': _selectedQuestions.length,
              'percentage': percentage,
              'award_level': awardLevel,
              'taken_at': DateTime.now().toIso8601String(),
            });
          }
        }
      } catch (e) {
        print('Error saving result: $e');
      }
    }
    
    if (mounted) {
      setState(() => _isSaving = false);
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
    });
    _selectRandomQuestions();
    _timer.cancel();
    _startTimer();
  }

  void _closeResults() {
    Navigator.pop(context); // Close results screen
    Navigator.pop(context); // Close test screen
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
      return _softBlue;
    }
    return _electricBlue;
  }

  double _getTimerProgress() {
    return _timeRemaining / 60;
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

    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Abstract Reasoning', style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Container(
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
                Padding(
                  padding: const EdgeInsets.all(kPadL),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Abstract Reasoning Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: kFontHeading,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Measure your pattern recognition and logical thinking',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: kFontBase,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                width: 70,
                                height: 70,
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
                                  fontSize: 16,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(kPadL, 0, kPadL, kPadM),
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF090A0E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kPadL, kPadL, kPadL, 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
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
                              color: _electricBlue.withOpacity(0.3),
                              width: 1,
                            ),
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
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: kPadL),
                      children: [
                        ...currentQuestion.options.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final option = entry.value;
                          final isSelected = _selectedOptionIndex == idx;
                          return GestureDetector(
                            onTap: () => _selectOption(idx),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? _electricBlue.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(kRadiusCard),
                                border: Border.all(
                                  color: isSelected ? _electricBlue : _electricBlue.withOpacity(0.5),
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
                                        color: isSelected ? _electricBlue : Colors.white54,
                                        width: 1.5,
                                      ),
                                      color: isSelected ? _electricBlue.withOpacity(0.2) : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + idx),
                                        style: TextStyle(
                                          color: isSelected ? _electricBlue : Colors.white70,
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
                                        color: isSelected ? _electricBlue : Colors.white,
                                        fontSize: kFontBase,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _selectedQuestions.length * 100).round();
    String emoji;
    String message;
    Color color;
    
    if (percentage >= 80) {
      emoji = '🏆';
      message = 'Excellent! Outstanding pattern recognition!';
      color = _electricBlue;
    } else if (percentage >= 60) {
      emoji = '🎯';
      message = 'Good job! Keep practicing to improve further.';
      color = _glowCyan;
    } else {
      emoji = '📈';
      message = 'Good effort! Review the patterns and try again.';
      color = Colors.red;
    }
    
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(color: Colors.white)),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(kPadXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _electricBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _electricBlue, width: 1),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 16),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score out of ${_selectedQuestions.length} correct',
                  style: const TextStyle(
                    fontSize: kFontBase,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: kFontTitle,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetTest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _electricBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: _electricBlue),
                        ),
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
