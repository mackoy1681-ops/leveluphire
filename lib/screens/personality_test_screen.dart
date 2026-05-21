import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/personality_questions.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';

class PersonalityTestScreen extends ConsumerStatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  ConsumerState<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends ConsumerState<PersonalityTestScreen> {
  // Three sections of questions
  List<Question> _workPersonalityQuestions = [];
  List<Question> _leadershipQuestions = [];
  List<Question> _teamQuestions = [];
  
  // Current section: 0 = Work Personality, 1 = Leadership, 2 = Team
  int _currentSection = 0;
  int _currentQuestionIndex = 0;
  
  // Store answers (index of selected option)
  Map<String, int> _answers = {};
  
  bool _testCompleted = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profilePhotoUrl;
  
  // Results
  String _workPersonalityResult = '';
  String _leadershipResult = '';
  String _teamResult = '';
  String _combinedSummary = '';

  // Cosmic Nebula Color Palette
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
    final workList = List<Question>.from(workPersonalityQuestions);
    final leadershipList = List<Question>.from(leadershipStyleQuestions);
    final teamList = List<Question>.from(teamCollaborationQuestions);
    
    workList.shuffle();
    leadershipList.shuffle();
    teamList.shuffle();
    
    setState(() {
      _workPersonalityQuestions = List<Question>.from(workList.take(10));
      _leadershipQuestions = List<Question>.from(leadershipList.take(10));
      _teamQuestions = List<Question>.from(teamList.take(10));
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
    } else if (_currentSection + 1 < 3) {
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
      case 0: return _workPersonalityQuestions;
      case 1: return _leadershipQuestions;
      default: return _teamQuestions;
    }
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case 0: return 'Work Personality';
      case 1: return 'Leadership Style';
      default: return 'Team Collaboration';
    }
  }

  String _getSectionDescription() {
    switch (_currentSection) {
      case 0:
        return 'Discover how you handle tasks, teamwork, and pressure';
      case 1:
        return 'Understand your decision-making and leadership approach';
      default:
        return 'Evaluate your cooperation and collaboration style';
    }
  }

  IconData _getSectionIcon() {
    switch (_currentSection) {
      case 0: return Icons.work_outline;
      case 1: return Icons.leaderboard;
      default: return Icons.group;
    }
  }

  void _calculateResults() {
    // Calculate Work Personality result
    int teamPreference = 0;
    int independentPreference = 0;
    
    for (var q in _workPersonalityQuestions) {
      int answer = _answers[q.id] ?? 2;
      if (q.id.contains('01') || q.id.contains('06') || q.id.contains('08') || 
          q.id.contains('10') || q.id.contains('28')) {
        teamPreference += answer;
      } 
      else if (q.id.contains('04') || q.id.contains('11') || q.id.contains('17')) {
        independentPreference += (4 - answer);
      }
    }
    
    if (teamPreference > independentPreference + 10) {
      _workPersonalityResult = 'Collaborator';
    } else if (independentPreference > teamPreference + 10) {
      _workPersonalityResult = 'Independent';
    } else {
      _workPersonalityResult = 'Balanced';
    }
    
    // Calculate Leadership result
    int democratic = 0;
    int autocratic = 0;
    
    for (var q in _leadershipQuestions) {
      int answer = _answers[q.id] ?? 2;
      if (q.id.contains('02') || q.id.contains('12') || q.id.contains('24')) {
        democratic += answer;
      } else if (q.id.contains('01') || q.id.contains('23')) {
        autocratic += answer;
      }
    }
    
    if (democratic > autocratic + 8) {
      _leadershipResult = 'Democratic Leader';
    } else if (autocratic > democratic + 8) {
      _leadershipResult = 'Autocratic Leader';
    } else {
      _leadershipResult = 'Transformational Leader';
    }
    
    // Calculate Team result
    int harmonizer = 0;
    int driver = 0;
    
    for (var q in _teamQuestions) {
      int answer = _answers[q.id] ?? 2;
      if (q.id.contains('04') || q.id.contains('20') || q.id.contains('08')) {
        harmonizer += answer;
      } else if (q.id.contains('07') || q.id.contains('21')) {
        driver += answer;
      }
    }
    
    if (harmonizer > driver + 10) {
      _teamResult = 'Harmonizer';
    } else if (driver > harmonizer + 10) {
      _teamResult = 'Driver';
    } else {
      _teamResult = 'Supporter';
    }
    
    _combinedSummary = _generateSummary();
    
    setState(() {
      _testCompleted = true;
    });
  }

  String _generateSummary() {
    String leadershipText = '';
    String workText = '';
    String teamText = '';
    
    if (_leadershipResult == 'Democratic Leader') {
      leadershipText = 'a democratic leader who seeks input from others';
    } else if (_leadershipResult == 'Autocratic Leader') {
      leadershipText = 'an autocratic leader who makes decisions independently';
    } else {
      leadershipText = 'a transformational leader who inspires others to grow';
    }
    
    if (_workPersonalityResult == 'Collaborator') {
      workText = 'thrives in team environments and enjoys collaboration';
    } else if (_workPersonalityResult == 'Independent') {
      workText = 'works best independently with minimal supervision';
    } else {
      workText = 'adapts well to both solo and team work';
    }
    
    if (_teamResult == 'Harmonizer') {
      teamText = 'naturally maintains peace and supports others';
    } else if (_teamResult == 'Driver') {
      teamText = 'focuses on getting results efficiently';
    } else {
      teamText = 'takes satisfaction in helping teammates succeed';
    }
    
    return 'You are $leadershipText who $workText and $teamText.';
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
          .eq('assessment_type', 'personality')
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
          'assessment_type': 'personality',
          'result_summary': _combinedSummary,
          'taken_at': DateTime.now().toIso8601String(),
        });
      }

      // Also save to user_awards for the badge (update or insert)
      final existingAward = await Supabase.instance.client
          .from('user_awards')
          .select()
          .eq('user_id', user.id)
          .eq('test_name', 'Behavioral')
          .maybeSingle();

      if (existingAward == null) {
        await Supabase.instance.client.from('user_awards').insert({
          'id': const Uuid().v4(),
          'user_id': user.id,
          'test_name': 'Behavioral',
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
          const SnackBar(content: Text('Personality profile saved to profile!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving personality result: $e');
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
    for (var q in _workPersonalityQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _leadershipQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    for (var q in _teamQuestions) {
      if (_answers.containsKey(q.id)) answered++;
    }
    return answered;
  }

  int _getTotalQuestions() {
    return _workPersonalityQuestions.length + 
           _leadershipQuestions.length + 
           _teamQuestions.length;
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
        title: const Text('Work Personality Profile', style: TextStyle(color: Colors.white)),
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
          // Header Section with Cosmic Nebula gradient
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
                              'Work Personality Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: kFontHeading,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Discover your work style, leadership approach, and how you collaborate',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: kFontBase,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Section ${_currentSection + 1} of 3',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: kFontSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Electric Blue Progress Circle
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
                                  value: (_currentSection * 10 + _currentQuestionIndex + 1) / 30,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                ),
                              ),
                              Text(
                                '${(_currentSection * 10 + _currentQuestionIndex + 1)}/30',
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
                
                // Electric Blue Progress Bar
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
          
          // Question Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF090A0E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kPadL),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    
                    // Section Indicator
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
                    
                    // Question number
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${currentQuestions.length}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Question Card
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
                    
                    // Options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final option = entry.value;
                      final isSelected = _answers[currentQuestion.id] == idx;
                      return _buildOptionCard(idx, option, isSelected, currentQuestion.id);
                    }),
                    const SizedBox(height: 24),
                    
                    // Next Button
                    SizedBox(
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
                              _currentSection == 2 && _currentQuestionIndex + 1 >= currentQuestions.length
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
                  ],
                ),
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
        title: const Text('Your Personality Profile', style: TextStyle(color: Colors.white)),
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
              
              // Celebration icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _electricBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _electricBlue, width: 1),
                ),
                child: const Icon(Icons.auto_awesome, size: 48, color: Color(0xFF00E5FF)),
              ),
              const SizedBox(height: 24),
              
              // Work Personality Result Card
              _buildResultCard(
                title: 'Work Personality',
                result: _workPersonalityResult,
                icon: Icons.work_outline,
                description: _workPersonalityResult == 'Collaborator'
                    ? 'You thrive in team settings and enjoy working with others'
                    : _workPersonalityResult == 'Independent'
                    ? 'You prefer working alone and taking initiative'
                    : 'You adapt well to both solo and team environments',
              ),
              const SizedBox(height: 16),
              
              // Leadership Result Card
              _buildResultCard(
                title: 'Leadership Style',
                result: _leadershipResult,
                icon: Icons.leaderboard,
                description: _leadershipResult == 'Democratic Leader'
                    ? 'You seek input from others before making decisions'
                    : _leadershipResult == 'Autocratic Leader'
                    ? 'You prefer making decisions independently'
                    : 'You inspire and motivate others to reach their potential',
              ),
              const SizedBox(height: 16),
              
              // Team Result Card
              _buildResultCard(
                title: 'Team Collaboration',
                result: _teamResult,
                icon: Icons.group,
                description: _teamResult == 'Harmonizer'
                    ? 'You prioritize peace and support team harmony'
                    : _teamResult == 'Driver'
                    ? 'You focus on results and efficient execution'
                    : 'You enjoy helping others and building strong relationships',
              ),
              const SizedBox(height: 24),
              
              // Combined Summary Card
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
                      'Your Personality Summary',
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
              
              // Buttons
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
    required String result,
    required IconData icon,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _deepSpace.withOpacity(0.5),
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: _electricBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _electricBlue, size: 28),
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
                  result,
                  style: TextStyle(
                    color: _electricBlue,
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