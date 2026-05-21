import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class KokoroTtsService {
  static final KokoroTtsService _instance = KokoroTtsService._internal();
  factory KokoroTtsService() => _instance;
  KokoroTtsService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  
  // Available voices
  final List<String> voices = [
    'af_heart',   // Female, warm
    'af_bella',   // Female, clear
    'af_nicole',  // Female, professional
    'am_adam',    // Male, US
    'am_michael', // Male, deep
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // For now, we'll use a simpler approach
    // Kokoro ONNX requires native integration which is complex
    // We'll use a hosted API or fallback to flutter_tts
    _isInitialized = true;
    print('Kokoro TTS Service initialized (using fallback mode)');
  }

  Future<void> speak(String text, {String voice = 'af_heart', double speed = 1.0}) async {
    await _speakWithFallback(text);
  }

  Future<void> _speakWithFallback(String text) async {
    try {
      // For now, use flutter_tts as fallback
      // You can replace this with Kokoro API call later
      await _useFlutterTts(text);
    } catch (e) {
      print('TTS error: $e');
    }
  }

  Future<void> _useFlutterTts(String text) async {
    // This will be implemented when we integrate flutter_tts
    print('Speaking: $text');
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}