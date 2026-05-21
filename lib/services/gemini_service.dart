import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/gemini.dart';
import '../models/assessment_model.dart';

class GeminiService {
  // ─── Assessment Questions ────────────────────────────────────────────────

  /// Generates [count] multiple-choice questions on [topic].
  static Future<List<AssessmentQuestion>> generateAssessmentQuestions({
    required String topic,
    int count = 10,
  }) async {
    final prompt = '''
Generate $count multiple-choice assessment questions about "$topic".
Return ONLY a valid JSON array with no markdown, no explanation. Format:
[
  {
    "text": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0
  }
]
correct_index is 0-based index into options array. Generate exactly $count items.
''';

    final body = await _callGemini(prompt);
    final jsonStr = _extractJson(body);
    final List<dynamic> parsed = json.decode(jsonStr) as List<dynamic>;
    return parsed.map((e) {
      final m = e as Map<String, dynamic>;
      return AssessmentQuestion(
        text: m['text'] as String,
        options: (m['options'] as List<dynamic>).map((o) => o as String).toList(),
        correctIndex: m['correct_index'] as int,
      );
    }).toList();
  }

  // ─── Interview Questions ─────────────────────────────────────────────────

  /// Generates [count] interview questions for the given [field].
  static Future<List<String>> generateInterviewQuestions({
    required String field,
    int count = 8,
  }) async {
    final prompt = '''
Generate $count professional job interview questions for someone applying as a "$field".
Return ONLY a valid JSON array of strings with no markdown, no explanation.
Example: ["Tell me about yourself.", "What is your greatest strength?"]
Generate exactly $count questions.
''';

    final body = await _callGemini(prompt);
    final jsonStr = _extractJson(body);
    final List<dynamic> parsed = json.decode(jsonStr) as List<dynamic>;
    return parsed.map((e) => e as String).toList();
  }

  // ─── Evaluate Answer ─────────────────────────────────────────────────────

  /// Evaluates a user's interview answer and returns concise feedback.
  static Future<String> evaluateAnswer({
    required String question,
    required String answer,
    required String field,
  }) async {
    final prompt = '''
You are an expert interview coach for "$field" roles.
Interview question: "$question"
Candidate's answer: "$answer"

Provide concise, constructive feedback in 2-4 sentences. 
Highlight what was good, what was missing, and give one actionable tip.
Do NOT use bullet points. Write as flowing prose.
''';

    final body = await _callGemini(prompt);
    return _extractText(body);
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _callGemini(String prompt) async {
    final response = await http.post(
      Uri.parse(GeminiConfig.generateContentUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(GeminiConfig.buildRequest(prompt)),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Extract JSON from Gemini response (strip possible markdown fences)
  static String _extractJson(Map<String, dynamic> body) {
    String text = _extractText(body);
    // Remove markdown code fences if present
    text = text.replaceAll(RegExp(r'```json\s*'), '');
    text = text.replaceAll(RegExp(r'```\s*'), '');
    return text.trim();
  }

  static String _extractText(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'] as List<dynamic>;
      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      return parts[0]['text'] as String;
    } catch (_) {
      throw const FormatException('Unexpected Gemini response format');
    }
  }
}
