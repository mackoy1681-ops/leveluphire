import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question_model.dart';
import '../utils/constants.dart';
import 'professional_exam_screen.dart';

class ProfessionalExamSetup extends StatefulWidget {
  const ProfessionalExamSetup({super.key});

  @override
  State<ProfessionalExamSetup> createState() => _ProfessionalExamSetupState();
}

class _ProfessionalExamSetupState extends State<ProfessionalExamSetup> {
  final TextEditingController _professionController = TextEditingController();

  @override
 void dispose() {
    _professionController.dispose();
    super.dispose();
  }

  void _startExam() async {
    final profession = _professionController.text.trim();
    if (profession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your profession or field')),
      );
      return;
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalExamLoading(profession: profession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Container(
        padding: const EdgeInsets.all(kPadL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Professional Exam',
                  style: TextStyle(
                    color: kPrimaryText,
                    fontSize: kFontTitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kSecondaryText),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kRadiusInput),
                border: Border.all(color: kError.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: kError, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '⚠️ Measures expert-level competency and real-world application',
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kRadiusInput),
                border: Border.all(color: kAccentBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: kAccentBlue, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No pressure, but your professional pride is on the line',
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Enter your profession or field',
              style: TextStyle(
                color: kSecondaryText,
                fontSize: kFontSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _professionController,
              decoration: InputDecoration(
                hintText: 'e.g. Software Engineer, Architect, Nurse, Accountant',
                hintStyle: const TextStyle(color: kSecondaryText, fontSize: 12),
                filled: true,
                fillColor: kBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadiusInput),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadiusInput),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadiusInput),
                  borderSide: const BorderSide(color: kAccentBlue, width: 2),
                ),
              ),
              style: const TextStyle(color: kPrimaryText),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Start Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalExamLoading extends StatefulWidget {
  final String profession;
  const ProfessionalExamLoading({super.key, required this.profession});

  @override
  State<ProfessionalExamLoading> createState() => _ProfessionalExamLoadingState();
}

class _ProfessionalExamLoadingState extends State<ProfessionalExamLoading> {
  String _loadingMessage = 'Generating your Professional Exam...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  Future<void> _generateQuestions() async {
    const String apiKey = 'AIzaSyDNj2VXd8i_lKZJ8O7sD3i1VVyOiKj1jMY';
    final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$apiKey';
    
    final prompt = '''
Generate a professional certification exam for a ${widget.profession}.

Create exactly 30 multiple-choice questions with the following difficulty distribution:
- Questions 1-10: Easy difficulty (basic concepts every ${widget.profession} should know)
- Questions 11-20: Medium difficulty (practical application and problem-solving)
- Questions 21-25: Hard difficulty (complex scenarios and edge cases)
- Questions 26-30: Extremely hard difficulty (expert-level, niche knowledge)

For each question, provide:
- The question text
- 4 answer options (A, B, C, D)
- The correct answer (A, B, C, or D)
- A brief explanation

Format the response as a JSON array with 30 objects. Each object must have exactly these fields:
{
  "question": "the question text",
  "options": ["option A", "option B", "option C", "option D"],
  "correct": "A",
  "explanation": "brief explanation"
}

Make the questions specific to ${widget.profession}. Return ONLY the JSON array, no other text.
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean the response
        String cleanText = text;
        if (cleanText.startsWith('```json')) cleanText = cleanText.substring(7);
        if (cleanText.startsWith('```')) cleanText = cleanText.substring(3);
        if (cleanText.endsWith('```')) cleanText = cleanText.substring(0, cleanText.length - 3);
        cleanText = cleanText.trim();
        
        final List<dynamic> questionsJson = jsonDecode(cleanText);
        final List<Question> questions = [];
        
        for (int i = 0; i < questionsJson.length; i++) {
          final q = questionsJson[i];
          int correctIndex = 0;
          switch (q['correct'].toString().toUpperCase()) {
            case 'A': correctIndex = 0; break;
            case 'B': correctIndex = 1; break;
            case 'C': correctIndex = 2; break;
            case 'D': correctIndex = 3; break;
          }
          
          String difficulty = 'medium';
          if (i < 10) difficulty = 'easy';
          else if (i < 20) difficulty = 'medium';
          else if (i < 25) difficulty = 'hard';
          else difficulty = 'extreme';
          
          questions.add(Question(
            id: 'prof_${i + 1}',
            text: q['question'],
            options: List<String>.from(q['options']),
            correctOptionIndex: correctIndex,
            difficulty: difficulty,
            explanation: q['explanation'],
          ));
        }
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessionalExamScreen(
                profession: widget.profession,
                questions: questions,
              ),
            ),
          );
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating questions: $e');
      setState(() {
        _loadingMessage = 'Failed to generate questions. Please try again.';
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kPadXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _hasError ? kError.withOpacity(0.1) : kAccentBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasError ? Icons.error_outline : Icons.auto_awesome,
                        size: 60,
                        color: _hasError ? kError : kAccentBlue,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontTitle,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              if (!_hasError) ...[
                const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: kSurface,
                    color: kAccentBlue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'This may take up to 3 minutes\nPlease wait',
                  style: TextStyle(
                    color: kSecondaryText,
                    fontSize: kFontBase,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentBlue,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}