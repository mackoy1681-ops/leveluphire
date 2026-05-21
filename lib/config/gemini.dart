import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  GeminiConfig._();

  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Using Gemini 1.5 Flash — fast, generous free tier
  static const String _model = 'gemini-1.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static String get generateContentUrl =>
      '$_baseUrl/$_model:generateContent?key=$apiKey';

  /// Build a request body for a text-only prompt
  static Map<String, dynamic> buildRequest(String prompt) {
    return {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      },
    };
  }
}
