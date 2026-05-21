import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';
import 'interview_summary.dart';

class InterviewScreen extends StatefulWidget {
  final String profession;
  final bool isFemale;
  final String imageFileName;

  const InterviewScreen({
    super.key,
    required this.profession,
    required this.isFemale,
    required this.imageFileName,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  List<Map<String, String>> _conversation = [];
  List<String> _questions = [];
  int _currentStep = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _interviewCompleted = false;
  List<String> _userAnswers = [];
  List<String> _questionFeedback = [];
  String? _currentAnswer;
  String? _aiSummary;
  bool _isEnding = false;

  late FlutterTts _flutterTts;
  late stt.SpeechToText _speechToText;
  late AudioPlayer _audioPlayer;
  Timer? _silenceTimer;
  Timer? _recordingTimer;

  static const String _apiKey = 'AIzaSyDNj2VXd8i_lKZJ8O7sD3i1VVyOiKj1jMY';
  final Random _random = Random();

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
    _audioPlayer = AudioPlayer();
    _generateQuestions();
  }

  void _initializeTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
    
    if (widget.isFemale) {
      _flutterTts.setVoice({"name": "en-US-Wavenet-F", "locale": "en-US"});
    } else {
      _flutterTts.setVoice({"name": "en-US-Wavenet-M", "locale": "en-US"});
    }
  }

  void _initializeSpeech() {
    _speechToText = stt.SpeechToText();
  }

  Future<void> _generateQuestions() async {
    setState(() => _isLoading = true);

    final prompt = '''
Generate 5 interview questions for a ${widget.profession} position.

The questions should be realistic, professional, and typical for a job interview in this field.
Mix of:
- 1 "Tell me about yourself" type question
- 2 behavioral questions (past experience)
- 1 technical/skill-based question
- 1 situational question (how would you handle X)

Format the response as a JSON array with 5 strings. Each string is one question.
Return ONLY the JSON array, no other text.
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        if (text.startsWith('```json')) text = text.substring(7);
        if (text.startsWith('```')) text = text.substring(3);
        if (text.endsWith('```')) text = text.substring(0, text.length - 3);
        text = text.trim();
        
        final List<dynamic> questionsJson = jsonDecode(text);
        setState(() {
          _questions = questionsJson.map((q) => q.toString()).toList();
          _isLoading = false;
          _userAnswers = List.filled(_questions.length, '');
          _questionFeedback = List.filled(_questions.length, '');
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          _startGreeting();
        });
      } else {
        _fallbackQuestions();
      }
    } catch (e) {
      print('Error generating questions: $e');
      _fallbackQuestions();
    }
  }

  void _fallbackQuestions() {
    setState(() {
      _questions = [
        'Tell me about yourself and your experience.',
        'Why are you interested in this position?',
        'Describe a challenge you faced and how you overcame it.',
        'What are your greatest strengths?',
        'Where do you see yourself in 5 years?',
      ];
      _isLoading = false;
      _userAnswers = List.filled(_questions.length, '');
      _questionFeedback = List.filled(_questions.length, '');
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _startGreeting();
    });
  }

  void _startGreeting() async {
    final greeting = "Hello! How are you doing today?";
    setState(() {
      _conversation.add({'type': 'ai', 'text': greeting});
    });
    await _flutterTts.speak(greeting);
    _currentStep = 0;
    _startListeningForGreeting();
  }

  void _startListeningForGreeting() {
    _startListening(onResult: (answer) {
      _handleGreetingResponse(answer);
    });
  }

  void _handleGreetingResponse(String answer) {
    setState(() {
      _conversation.add({'type': 'user', 'text': answer});
    });
    _sayTransition();
  }

  void _sayTransition() async {
    final transition = "That's great to hear. Let's begin the interview.";
    setState(() {
      _conversation.add({'type': 'ai', 'text': transition});
    });
    await _flutterTts.speak(transition);
    _currentStep = 1;
    Future.delayed(const Duration(milliseconds: 500), () {
      _askFirstQuestion();
    });
  }

  void _askFirstQuestion() {
    if (_questions.isEmpty) return;
    _currentStep = 2;
    _speakQuestion();
  }

  void _speakQuestion() async {
    if (_currentStep - 2 >= _questions.length) {
      _completeInterview();
      return;
    }
    
    final question = _questions[_currentStep - 2];
    setState(() {
      _conversation.add({'type': 'ai', 'text': question});
    });
    await _flutterTts.speak(question);
  }

  void _startListeningForAnswer() {
    _startListening(onResult: (answer) {
      _handleAnswerResponse(answer);
    });
  }

  void _handleAnswerResponse(String answer) {
    setState(() {
      _conversation.add({'type': 'user', 'text': answer});
      _userAnswers[_currentStep - 2] = answer;
    });
    _evaluateAnswer(answer);
  }

  void _startListening({required Function(String) onResult}) {
    _startListeningInternal(onResult);
  }

  void _startListeningInternal(Function(String) onResult) async {
    if (_isListening || _isProcessing) return;
    
    bool available = await _speechToText.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _currentAnswer = '';
    });

    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    
    _recordingTimer = Timer(const Duration(seconds: 30), () {
      if (_isListening) {
        _stopListeningAndSubmit(onResult);
      }
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _currentAnswer = result.recognizedWords;
        });
        
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 4), () {
          if (_isListening) {
            _stopListeningAndSubmit(onResult);
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  void _stopListeningAndSubmit(Function(String) onResult) async {
    if (!_isListening) return;
    
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    
    await _speechToText.stop();
    
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    
    final answer = _currentAnswer ?? '';
    onResult(answer);
  }

  Future<void> _evaluateAnswer(String answer) async {
    setState(() => _isProcessing = true);

    final prompt = '''
As an interviewer for a ${widget.profession} position, evaluate this candidate's answer.

Question: ${_questions[_currentStep - 2]}
Candidate's answer: "$answer"

Provide a brief, constructive feedback (2-3 sentences). Include:
- One strength
- One area for improvement
- A tip for better answers

Keep it professional and encouraging. Return ONLY the feedback text, no JSON.
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String feedback = data['candidates'][0]['content']['parts'][0]['text'];
        
        setState(() {
          _questionFeedback[_currentStep - 2] = feedback;
          _score++;
          _isProcessing = false;
        });
        
        await _playRandomResponse();
        _moveToNextQuestion();
      } else {
        _simpleMoveToNext();
      }
    } catch (e) {
      print('Error evaluating answer: $e');
      _simpleMoveToNext();
    }
  }

  Future<void> _playRandomResponse() async {
    final responses = [
      "Thank you for sharing that.",
      "I appreciate your perspective.",
      "That's interesting, thank you.",
      "Good answer. Let me ask you another question.",
    ];
    final randomResponse = responses[_random.nextInt(responses.length)];
    await _flutterTts.speak(randomResponse);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _simpleMoveToNext() {
    setState(() {
      _questionFeedback[_currentStep - 2] = 'Answer recorded.';
      _score++;
      _isProcessing = false;
    });
    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    _currentStep++;
    if (_currentStep - 2 < _questions.length) {
      _speakQuestion();
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListeningForAnswer();
      });
    } else {
      _completeInterview();
    }
  }

  Future<void> _playEndSound() async {
    try {
      await _audioPlayer.play(AssetSource('sound/end.wav'));
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (e) {
      print('Error playing end sound: $e');
    }
  }

  Future<void> _completeInterview() async {
    setState(() => _interviewCompleted = true);
    
    await _flutterTts.speak(
      "Thank you for your time today. We'll review your responses and get back to you within a week. Have a great day!"
    );
    
    await Future.delayed(const Duration(seconds: 2));
    await _playEndSound();
    await _generateSummary();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => InterviewSummary(
          profession: widget.profession,
          score: _score,
          totalQuestions: _questions.length,
          percentage: (_score / _questions.length * 100).round(),
          questions: _questions,
          userAnswers: _userAnswers,
          feedback: _questionFeedback,
          aiSummary: _aiSummary,
        ),
      ).then((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _generateSummary() async {
    final percentage = (_score / _questions.length * 100).round();
    
    final prompt = '''
Based on a ${widget.profession} interview, provide a summary for a candidate who answered ${_score} out of ${_questions.length} questions well.

Questions and answers:
${_questions.asMap().entries.map((entry) => 
  "Q${entry.key + 1}: ${entry.value}\nA: ${_userAnswers[entry.key]}\nFeedback: ${_questionFeedback[entry.key]}"
).join('\n\n')}

Provide a JSON object with:
{
  "strengths": ["strength 1", "strength 2", "strength 3"],
  "improvements": ["area 1", "area 2"],
  "overall": "2-3 sentence overall summary"
}

Return ONLY the JSON object.
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        if (text.startsWith('```json')) text = text.substring(7);
        if (text.startsWith('```')) text = text.substring(3);
        if (text.endsWith('```')) text = text.substring(0, text.length - 3);
        text = text.trim();
        
        final summaryData = jsonDecode(text);
        setState(() {
          _aiSummary = summaryData['overall'];
        });
        await _saveToDatabase();
      } else {
        _aiSummary = 'You completed the interview. Your score was $_score out of ${_questions.length}. Continue practicing to improve your interview skills.';
        await _saveToDatabase();
      }
    } catch (e) {
      _aiSummary = 'You completed the interview. Your score was $_score out of ${_questions.length}. Continue practicing to improve your interview skills.';
      await _saveToDatabase();
    }
  }

  Future<void> _saveToDatabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final percentage = (_score / _questions.length * 100).round();
    
    try {
      await Supabase.instance.client.from('interview_results').insert({
        'id': const Uuid().v4(),
        'user_id': user.id,
        'profession': widget.profession,
        'score': _score,
        'total_questions': _questions.length,
        'percentage': percentage,
        'summary': _aiSummary,
        'taken_at': DateTime.now().toIso8601String(),
      });

      final existingAward = await Supabase.instance.client
          .from('user_awards')
          .select()
          .eq('user_id', user.id)
          .eq('test_name', 'Interview Practice')
          .maybeSingle();

      if (existingAward == null) {
        await Supabase.instance.client.from('user_awards').insert({
          'id': const Uuid().v4(),
          'user_id': user.id,
          'test_name': 'Interview Practice',
          'score': _score,
          'total_questions': _questions.length,
          'percentage': percentage,
          'award_level': 'taken',
          'taken_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving interview result: $e');
    }
  }

  Future<void> _endCall() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);
    
    if (!_interviewCompleted && _currentStep < _questions.length + 1) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: kSurface,
          title: const Text('End Interview?', style: TextStyle(color: kPrimaryText)),
          content: const Text(
            'Are you sure you want to end the interview early?\n\nNo summary will be saved.',
            style: TextStyle(color: kSecondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continue', style: TextStyle(color: kSecondaryText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: kError),
              child: const Text('End'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        setState(() => _isEnding = false);
        return;
      }
    }
    
    await _flutterTts.stop();
    await _speechToText.stop();
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    await _playEndSound();
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    _audioPlayer.dispose();
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Interview', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _endCall,
        ),
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
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preparing your interview...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(kPadL),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _electricBlue, width: 2),
                              image: DecorationImage(
                                image: AssetImage('assets/interviewer/${widget.imageFileName}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isListening)
                            Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSoundWaveBar(0.3),
                                  _buildSoundWaveBar(0.6),
                                  _buildSoundWaveBar(0.9),
                                  _buildSoundWaveBar(0.4),
                                  _buildSoundWaveBar(0.7),
                                ],
                              ),
                            ),

                          if (_conversation.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.all(kPadL),
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(kRadiusCard),
                                border: Border.all(color: kBorderColor),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'AI Interviewer:',
                                    style: TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontSize: kFontSmall,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _conversation.last['text'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: kFontTitle,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                          if (_isProcessing)
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(kPadL),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border(top: BorderSide(color: kBorderColor)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _endCall,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: kError.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: kError, width: 2),
                            ),
                            child: const Icon(Icons.call_end, size: 28, color: kError),
                          ),
                        ),
                        
                        if (!_interviewCompleted && !_isProcessing)
                          const SizedBox(width: 70, height: 70),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSoundWaveBar(double heightFactor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 20 + (20 * heightFactor),
      width: 4,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _electricBlue,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}