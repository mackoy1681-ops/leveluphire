import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/integrity_questions.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';

class IntegrityTestScreen extends ConsumerStatefulWidget {
  const IntegrityTestScreen({super.key});

  @override
  ConsumerState<IntegrityTestScreen> createState() => _IntegrityTestScreenState();
}

class _IntegrityTestScreenState extends ConsumerState<IntegrityTestScreen> {
  // Six sections of questions
  List<Question> _workEthicsQuestions = [];
  List<Question> _integrityQuestions = [];
  List<Question> _selfDisciplineQuestions = [];
  List<Question> _accountabilityQuestions = [];
  List<Question> _reliabilityQuestions = [];
  List<Question> _professionalismQuestions = [];
  
  // Current section: 0-5
  int _currentSection = 0;
  int _currentQuestionIndex = 0;
  
  // Store answers
  Map<String, int> _answers = {};
  
  bool _testCompleted = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profilePhotoUrl;
  
  // Results for each category
  String _workEthicsResult = '';
  String _integrityResult = '';
  String _selfDisciplineResult = '';
  String _accountabilityResult = '';
  String _reliabilityResult = '';
  String _professionalismResult = '';
  String _combinedSummary = '';

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);
  final Color _glowCyan = const Color(0xFF00B4D8);

  @override
  void initState() {
    super.initState();
    _loadRandomQuestions();
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

  void _loadRandomQuestions() {
    final workEthicsList = List<Question>.from(workEthicsQuestions);
    final integrityList = List<Question>.from(integrityScaleQuestions);
    final selfDisciplineList = List<Question>.from(selfDisciplineQuestions);
    final accountabilityList = List<Question>.from(accountabilityQuestions);
    final reliabilityList = List<Question>.from(reliabilityQuestions);
    final professionalismList = List<Question>.from(professionalismQuestions);
    
    workEthicsList.shuffle();
    integrityList.shuffle();
    selfDisciplineList.shuffle();
    accountabilityList.shuffle();
    reliabilityList.shuffle();
    professionalismList.shuffle();
    
    setState(() {
      _workEthicsQuestions = List<Question>.from(workEthicsList.take(5));
      _integrityQuestions = List<Question>.from(integrityList.take(5));
      _selfDisciplineQuestions = List<Question>.from(selfDisciplineList.take(5));
      _accountabilityQuestions = List<Question>.from(accountabilityList.take(5));
      _reliabilityQuestions = List<Question>.from(reliabilityList.take(5));
      _professionalismQuestions = List<Question>.from(professionalismList.take(5));
      _isLoading = false;
    });
  }

  void _selectAnswer(int optionIndex) {
    HapticFeedback.lightImpact();
    
    setState(() {
      String questionId = _getCurrentQuestions()[_currentQuestionIndex].id;
      _answers[questionId] = optionIndex;
    });
  }

  void _nextQuestion() {
    HapticFeedback.selectionClick();
    
    final List<Question> currentQuestions = _getCurrentQuestions();
    
    if (_currentQuestionIndex + 1 < currentQuestions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else if (_currentSection + 1 < 6) {
      setState(() {
        _currentSection++;
        _currentQuestionIndex = 0;
      });
    } else {
      _calculateResults();
    }
  }

  List<Question> _getCurrentQuestions() {
    switch (_currentSection) {
      case 0: return _workEthicsQuestions;
      case 1: return _integrityQuestions;
      case 2: return _selfDisciplineQuestions;
      case 3: return _accountabilityQuestions;
      case 4: return _reliabilityQuestions;
      default: return _professionalismQuestions;
    }
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case 0: return 'Work Ethics';
      case 1: return 'Integrity Scale';
      case 2: return 'Self-Discipline';
      case 3: return 'Accountability';
      case 4: return 'Reliability';
      default: return 'Professionalism';
    }
  }

  String _getSectionDescription() {
    switch (_currentSection) {
      case 0:
        return 'Measures punctuality, responsibility, and dedication';
      case 1:
        return 'Assesses honesty, rule-following, and trustworthiness';
      case 2:
        return 'Measures focus, avoiding distractions, and meeting deadlines';
      case 3:
        return 'Evaluates taking responsibility and admitting mistakes';
      case 4:
        return 'Measures follow-through, dependability, and consistency';
      default:
        return 'Assesses respect, boundaries, and workplace behavior';
    }
  }

  IconData _getSectionIcon() {
    switch (_currentSection) {
      case 0: return Icons.work_outline;
      case 1: return Icons.gpp_good;
      case 2: return Icons.self_improvement;
      case 3: return Icons.verified_user;
      case 4: return Icons.assignment_turned_in;
      default: return Icons.people_outline;
    }
  }

  void _calculateResults() {
    _workEthicsResult = _calculateCategoryScore(_workEthicsQuestions);
    _integrityResult = _calculateCategoryScore(_integrityQuestions);
    _selfDisciplineResult = _calculateCategoryScore(_selfDisciplineQuestions);
    _accountabilityResult = _calculateCategoryScore(_accountabilityQuestions);
    _reliabilityResult = _calculateCategoryScore(_reliabilityQuestions);
    _professionalismResult = _calculateCategoryScore(_professionalismQuestions);
    
    _combinedSummary = _generateSummary();
    
    setState(() {
      _testCompleted = true;
    });
  }

  String _calculateCategoryScore(List<Question> questions) {
    int totalScore = 0;
    for (var q in questions) {
      int answer = _answers[q.id] ?? 2;
      totalScore += answer;
    }
    double average = totalScore / questions.length;
    
    if (average >= 3.5) return 'High';
    if (average >= 2.5) return 'Moderate';
    return 'Low';
  }

  String _getScoreDescription(String level, String category) {
    if (level == 'High') {
      switch (category) {
        case 'Work Ethics':
          return 'You consistently meet deadlines and take responsibility seriously.';
        case 'Integrity Scale':
          return 'You believe in honesty and doing the right thing, even when no one is watching.';
        case 'Self-Discipline':
          return 'You stay focused and consistently meet your goals.';
        case 'Accountability':
          return 'You own your mistakes and follow through on commitments.';
        case 'Reliability':
          return 'Others can count on you to deliver what you promised.';
        default:
          return 'You communicate respectfully and maintain professional boundaries.';
      }
    } else if (level == 'Moderate') {
      switch (category) {
        case 'Work Ethics':
          return 'Good foundation. With practice, you can strengthen this further.';
        case 'Integrity Scale':
          return 'You generally do the right thing but could improve consistency.';
        case 'Self-Discipline':
          return 'You stay focused most of the time but sometimes get distracted.';
        case 'Accountability':
          return 'You take responsibility usually but could improve follow-through.';
        case 'Reliability':
          return 'You are dependable but occasionally miss commitments.';
        default:
          return 'You maintain professionalism most of the time.';
      }
    } else {
      switch (category) {
        case 'Work Ethics':
          return 'Needs improvement. Consider setting small daily goals to build this habit.';
        case 'Integrity Scale':
          return 'Focus on being consistent in your ethical choices daily.';
        case 'Self-Discipline':
          return 'Try creating routines and removing distractions to improve focus.';
        case 'Accountability':
          return 'Practice admitting mistakes early and taking corrective action.';
        case 'Reliability':
          return 'Start with small commitments and consistently deliver on time.';
        default:
          return 'Focus on respecting boundaries and maintaining positive workplace behavior.';
      }
    }
  }

  String _generateSummary() {
    List<String> highTraits = [];
    List<String> moderateTraits = [];
    List<String> lowTraits = [];
    
    if (_workEthicsResult == 'High') highTraits.add('strong work ethics');
    else if (_workEthicsResult == 'Moderate') moderateTraits.add('work ethics');
    else lowTraits.add('work ethics');
    
    if (_integrityResult == 'High') highTraits.add('high integrity');
    else if (_integrityResult == 'Moderate') moderateTraits.add('integrity');
    else lowTraits.add('integrity');
    
    if (_selfDisciplineResult == 'High') highTraits.add('strong self-discipline');
    else if (_selfDisciplineResult == 'Moderate') moderateTraits.add('self-discipline');
    else lowTraits.add('self-discipline');
    
    if (_accountabilityResult == 'High') highTraits.add('accountability');
    else if (_accountabilityResult == 'Moderate') moderateTraits.add('accountability');
    else lowTraits.add('accountability');
    
    if (_reliabilityResult == 'High') highTraits.add('reliability');
    else if (_reliabilityResult == 'Moderate') moderateTraits.add('reliability');
    else lowTraits.add('reliability');
    
    if (_professionalismResult == 'High') highTraits.add('professionalism');
    else if (_professionalismResult == 'Moderate') moderateTraits.add('professionalism');
    else lowTraits.add('professionalism');
    
    String summary = '';
    if (highTraits.isNotEmpty) {
      summary += 'You demonstrate ${highTraits.join(', ')}. ';
    }
    if (moderateTraits.isNotEmpty) {
      summary += 'Your ${moderateTraits.join(', ')} are developing well. ';
    }
    if (lowTraits.isNotEmpty) {
      summary += 'Consider improving your ${lowTraits.join(', ')}. ';
    }
    
    return summary;
  }

  Future<void> _saveToProfile() async {
    setState(() => _isSaving = true);
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to save results')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Check if assessment already exists
      final existing = await Supabase.instance.client
          .from('user_assessments')
          .select()
          .eq('user_id', user.id)
          .eq('assessment_type', 'integrity')
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        await Supabase.instance.client
            .from('user_assessments')
            .update({
              'result_summary': _combinedSummary,
              'taken_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
      } else {
        // Insert new record
        await Supabase.instance.client.from('user_assessments').insert({
          'id': const Uuid().v4(),
          'user_id': user.id,
          'assessment_type': 'integrity',
          'result_summary': _combinedSummary,
          'taken_at': DateTime.now().toIso8601String(),
        });
      }

      // Also save to user_awards for the badge (update or insert)
      final existingAward = await Supabase.instance.client
          .from('user_awards')
          .select()
          .eq('user_id', user.id)
          .eq('test_name', 'Integrity')
          .maybeSingle();

      if (existingAward == null) {
        await Supabase.instance.client.from('user_awards').insert({
          'id': const Uuid().v4(),
          'user_id': user.id,
          'test_name': 'Integrity',
          'score': 0,
          'total_questions': 30,
          'percentage': 100,
          'award_level': 'taken',
          'taken_at': DateTime.now().toIso8601String(),
        });
      } else {
        await Supabase.instance.client
            .from('user_awards')
            .update({
              'taken_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingAward['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Integrity profile saved to profile!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving integrity result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _getCurrentProgress() {
    int answered = 0;
    for (var q in _workEthicsQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _integrityQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _selfDisciplineQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _accountabilityQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _reliabilityQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _professionalismQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    return answered;
  }

  int _getTotalQuestions() {
    return _workEthicsQuestions.length + 
           _integrityQuestions.length + 
           _selfDisciplineQuestions.length +
           _accountabilityQuestions.length +
           _reliabilityQuestions.length +
           _professionalismQuestions.length;
  }

  void _resetTest() {
    setState(() {
      _currentSection = 0;
      _currentQuestionIndex = 0;
      _answers = {};
      _testCompleted = false;
    });
    _loadRandomQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C10),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }

    if (_testCompleted) {
      return _buildResultsScreen();
    }

    final currentQuestions = _getCurrentQuestions();
    final currentQuestion = currentQuestions[_currentQuestionIndex];
    final totalQuestions = _getTotalQuestions();
    final answeredCount = _getCurrentProgress();
    final progress = answeredCount / totalQuestions;

    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Integrity & Work Habits', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                              'Integrity & Work Habits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: kFontHeading,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Assess your work ethics, integrity, and professionalism',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: kFontBase,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Section ${_currentSection + 1} of 6',
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
                                  value: (_currentSection * 5 + _currentQuestionIndex + 1) / 30,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                ),
                              ),
                              Text(
                                '${(_currentSection * 5 + _currentQuestionIndex + 1)}/30',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 12,
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
                      value: progress,
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
                        Row(
                          children: [
                            Icon(_getSectionIcon(), color: _electricBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _getSectionTitle(),
                              style: TextStyle(
                                color: _electricBlue,
                                fontSize: kFontSmall,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSectionDescription(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: kFontSmall,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${currentQuestions.length}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          final isSelected = _answers[currentQuestion.id] == idx;
                          return _buildOptionCard(idx, option, isSelected, currentQuestion.id);
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kPadL, 12, kPadL, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _electricBlue,
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
                              _currentSection == 5 && _currentQuestionIndex + 1 >= currentQuestions.length
                                  ? 'See Results'
                                  : 'Next Section',
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

  Widget _buildOptionCard(int idx, String option, bool isSelected, String questionId) {
    return GestureDetector(
      onTap: () => _selectAnswer(idx),
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
  }

  Widget _buildResultsScreen() {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Your Integrity Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _electricBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _electricBlue, width: 1),
                ),
                child: const Icon(Icons.shield, size: 48, color: Color(0xFF00E5FF)),
              ),
              const SizedBox(height: 24),
              _buildResultCard(
                title: 'Work Ethics',
                level: _workEthicsResult,
                icon: Icons.work_outline,
                description: _getScoreDescription(_workEthicsResult, 'Work Ethics'),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Integrity Scale',
                level: _integrityResult,
                icon: Icons.gpp_good,
                description: _getScoreDescription(_integrityResult, 'Integrity Scale'),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Self-Discipline',
                level: _selfDisciplineResult,
                icon: Icons.self_improvement,
                description: _getScoreDescription(_selfDisciplineResult, 'Self-Discipline'),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Accountability',
                level: _accountabilityResult,
                icon: Icons.verified_user,
                description: _getScoreDescription(_accountabilityResult, 'Accountability'),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Reliability',
                level: _reliabilityResult,
                icon: Icons.assignment_turned_in,
                description: _getScoreDescription(_reliabilityResult, 'Reliability'),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Professionalism',
                level: _professionalismResult,
                icon: Icons.people_outline,
                description: _getScoreDescription(_professionalismResult, 'Professionalism'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: _electricBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: _electricBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Integrity Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: kFontTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _combinedSummary,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: kFontBase,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                      child: const Text('Take Again'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveToProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _electricBlue,
                        foregroundColor: _deepSpace,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save to Profile'),
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

  Widget _buildResultCard({
    required String title,
    required String level,
    required IconData icon,
    required String description,
  }) {
    Color levelColor;
    if (level == 'High') {
      levelColor = _electricBlue;
    } else if (level == 'Moderate') {
      levelColor = _glowCyan;
    } else {
      levelColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _deepSpace.withOpacity(0.5),
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: _electricBlue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: levelColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: kFontSmall,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
