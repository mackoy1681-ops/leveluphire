import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class EssayResult extends StatefulWidget {
  final String topic;
  final String essayText;
  final int wordCount;

  const EssayResult({
    super.key,
    required this.topic,
    required this.essayText,
    required this.wordCount,
  });

  @override
  State<EssayResult> createState() => _EssayResultState();
}

class _EssayResultState extends State<EssayResult> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  
  // Grading results
  int _scoreContent = 0;
  int _scoreStructure = 0;
  int _scoreGrammar = 0;
  int _scoreClarity = 0;
  int _scoreCreativity = 0;
  int _percentage = 0;
  String _grade = '';
  String _feedback = '';
  String _summary = '';
  String _strengths = '';
  String _weaknesses = '';

  static const String _apiKey = 'AIzaSyDNj2VXd8i_lKZJ8O7sD3i1VVyOiKj1jMY';

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _gradeEssay();
  }

  Future<void> _gradeEssay() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prompt = '''
You are an expert essay grader. Grade the following essay based on these criteria:

Essay Topic: ${widget.topic}
Essay Text: "${widget.essayText}"
Word Count: ${widget.wordCount}

Grading Criteria (30 points max per category, but scaled to 20 for Grammar/Clarity/Creativity):
1. Content (30 points): Relevance to topic, depth of insight, accuracy of information
2. Structure (25 points): Introduction, body paragraphs, conclusion, logical flow
3. Grammar (20 points): Spelling, punctuation, sentence structure
4. Clarity (15 points): Readability, conciseness, avoiding ambiguity
5. Creativity (10 points): Originality, engaging writing, unique perspective

Score each category out of its maximum (30, 25, 20, 15, 10).

Also provide:
- Overall percentage (0-100)
- Letter grade (A=90-100%, B=80-89%, C=70-79%, D=60-69%, F=below 60%)
- Detailed feedback (2-3 sentences)
- Positive summary (1-2 sentences, encouraging tone)
- Strengths (2 bullet points)
- Weaknesses (2 bullet points)

Return ONLY valid JSON in this exact format:
{
  "content": 0,
  "structure": 0,
  "grammar": 0,
  "clarity": 0,
  "creativity": 0,
  "percentage": 0,
  "grade": "A",
  "feedback": "feedback text",
  "summary": "positive summary text",
  "strengths": "strength1, strength2",
  "weaknesses": "weakness1, weakness2"
}
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
        
        // Clean response
        if (text.startsWith('```json')) text = text.substring(7);
        if (text.startsWith('```')) text = text.substring(3);
        if (text.endsWith('```')) text = text.substring(0, text.length - 3);
        text = text.trim();
        
        final result = jsonDecode(text);
        
        setState(() {
          _scoreContent = result['content'];
          _scoreStructure = result['structure'];
          _scoreGrammar = result['grammar'];
          _scoreClarity = result['clarity'];
          _scoreCreativity = result['creativity'];
          _percentage = result['percentage'];
          _grade = result['grade'];
          _feedback = result['feedback'];
          _summary = result['summary'];
          _strengths = result['strengths'];
          _weaknesses = result['weaknesses'];
          _isLoading = false;
        });
        
        // Auto-save to database if score >= 76%
        if (_percentage >= 76) {
          await _saveToDatabase();
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error grading essay: $e');
      setState(() {
        _error = 'Failed to grade essay. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToDatabase() async {
    setState(() => _isSaving = true);
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Check if existing essay result with higher score
      final existing = await Supabase.instance.client
          .from('essay_results')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing == null || _percentage > (existing['percentage'] ?? 0)) {
        if (existing != null) {
          // Update existing record
          await Supabase.instance.client
              .from('essay_results')
              .update({
                'topic': widget.topic,
                'essay_text': widget.essayText,
                'word_count': widget.wordCount,
                'score_content': _scoreContent,
                'score_structure': _scoreStructure,
                'score_grammar': _scoreGrammar,
                'score_clarity': _scoreClarity,
                'score_creativity': _scoreCreativity,
                'percentage': _percentage,
                'grade': _grade,
                'feedback': _feedback,
                'summary': _summary,
                'taken_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existing['id']);
        } else {
          // Insert new record
          await Supabase.instance.client.from('essay_results').insert({
            'id': const Uuid().v4(),
            'user_id': user.id,
            'topic': widget.topic,
            'essay_text': widget.essayText,
            'word_count': widget.wordCount,
            'score_content': _scoreContent,
            'score_structure': _scoreStructure,
            'score_grammar': _scoreGrammar,
            'score_clarity': _scoreClarity,
            'score_creativity': _scoreCreativity,
            'percentage': _percentage,
            'grade': _grade,
            'feedback': _feedback,
            'summary': _summary,
            'taken_at': DateTime.now().toIso8601String(),
          });
        }

        // Also save award to user_awards (icon #8)
        final existingAward = await Supabase.instance.client
            .from('user_awards')
            .select()
            .eq('user_id', user.id)
            .eq('test_name', 'Essay Writing')
            .maybeSingle();

        if (existingAward == null) {
          await Supabase.instance.client.from('user_awards').insert({
            'id': const Uuid().v4(),
            'user_id': user.id,
            'test_name': 'Essay Writing',
            'score': _scoreContent + _scoreStructure + _scoreGrammar + _scoreClarity + _scoreCreativity,
            'total_questions': 100,
            'percentage': _percentage,
            'award_level': _percentage >= 80 ? 'gold' : 'silver',
            'taken_at': DateTime.now().toIso8601String(),
          });
        } else {
          if (_percentage > (existingAward['percentage'] ?? 0)) {
            await Supabase.instance.client
                .from('user_awards')
                .update({
                  'score': _scoreContent + _scoreStructure + _scoreGrammar + _scoreClarity + _scoreCreativity,
                  'percentage': _percentage,
                  'award_level': _percentage >= 80 ? 'gold' : 'silver',
                  'taken_at': DateTime.now().toIso8601String(),
                })
                .eq('id', existingAward['id']);
          }
        }
      }
    } catch (e) {
      print('Error saving essay result: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _closeResults() {
    Navigator.pop(context); // Close results screen
    Navigator.pop(context); // Close essay writing screen
  }

  void _retake() {
    Navigator.pop(context); // Close results
    Navigator.pop(context); // Close writing screen
    // User can start new essay from assessment page
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _deepSpace,
        appBar: AppBar(
          title: const Text('Grading Your Essay', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _closeResults,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_deepSpace, _nebulaBlue],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF00E5FF)),
                SizedBox(height: 16),
                Text(
                  'AI is grading your essay...',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _deepSpace,
        appBar: AppBar(
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _closeResults,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _gradeEssay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _electricBlue,
                  foregroundColor: _deepSpace,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final passed = _percentage >= 76;
    final gradeColor = _percentage >= 90 ? kSuccess : 
                       _percentage >= 80 ? _electricBlue : 
                       _percentage >= 70 ? Colors.orange : Colors.red;

    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Essay Results', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _closeResults,
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_deepSpace, _nebulaBlue],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadL),
          child: Column(
            children: [
              // Score Circle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: gradeColor, width: 2),
                ),
                child: Text(
                  '$_percentage%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Grade: $_grade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
              if (passed)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                  child: const Text(
                    'Badge Earned! 🏆',
                    style: TextStyle(color: kSuccess, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Score Breakdown
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  children: [
                    _buildScoreRow('Content', _scoreContent, 30),
                    const SizedBox(height: 12),
                    _buildScoreRow('Structure', _scoreStructure, 25),
                    const SizedBox(height: 12),
                    _buildScoreRow('Grammar', _scoreGrammar, 20),
                    const SizedBox(height: 12),
                    _buildScoreRow('Clarity', _scoreClarity, 15),
                    const SizedBox(height: 12),
                    _buildScoreRow('Creativity', _scoreCreativity, 10),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Strengths
              if (_strengths.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(kPadL),
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kSuccess.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.thumb_up, color: kSuccess, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Strengths',
                            style: TextStyle(
                              color: kSuccess,
                              fontSize: kFontSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._strengths.split(',').map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: kSuccess)),
                            Expanded(
                              child: Text(
                                s.trim(),
                                style: const TextStyle(color: Colors.white70, fontSize: kFontSmall),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Areas to Improve
              if (_weaknesses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(kPadL),
                  decoration: BoxDecoration(
                    color: kError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kError.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.thumb_down, color: kError, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Areas to Improve',
                            style: TextStyle(
                              color: kError,
                              fontSize: kFontSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._weaknesses.split(',').map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: kError)),
                            Expanded(
                              child: Text(
                                w.trim(),
                                style: const TextStyle(color: Colors.white70, fontSize: kFontSmall),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Feedback
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: _electricBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: _electricBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: kFontSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _feedback,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: kFontBase,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retake,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _electricBlue,
                        side: BorderSide(color: _electricBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int score, int max) {
    final percentage = (score / max * 100).round();
    Color color = percentage >= 80 ? kSuccess : percentage >= 60 ? _electricBlue : Colors.orange;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: kFontSmall,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusPill),
            child: LinearProgressIndicator(
              value: score / max,
              backgroundColor: kSurface,
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(
            '$score/$max',
            style: TextStyle(
              color: color,
              fontSize: kFontSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}