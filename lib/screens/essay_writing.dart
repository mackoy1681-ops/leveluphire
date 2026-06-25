import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../models/route_args.dart';

class EssayWriting extends StatefulWidget {
  final String topic;

  const EssayWriting({
    super.key,
    required this.topic,
  });

  @override
  State<EssayWriting> createState() => _EssayWritingState();
}

class _EssayWritingState extends State<EssayWriting> {
  final TextEditingController _essayController = TextEditingController();
  int _timeRemaining = 30 * 60; // 30 minutes in seconds
  late Timer _timer;
  bool _isSubmitting = false;
  bool _isTimerRunning = true;
  int _wordCount = 0;
  final int _targetWordCount = 250;

  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _startTimer();
    _essayController.addListener(_updateWordCount);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_timeRemaining > 0 && _isTimerRunning) {
          _timeRemaining--;
        } else if (_timeRemaining == 0) {
          _timer.cancel();
          _autoSubmit();
        }
      });
    });
  }

  void _updateWordCount() {
    final text = _essayController.text;
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    if (_wordCount != words) {
      setState(() {
        _wordCount = words;
      });
    }
  }

  void _autoSubmit() async {
    if (_isSubmitting) return;
    await _submitEssay();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getWordProgress() {
    return (_wordCount / _targetWordCount).clamp(0.0, 1.0);
  }

  Color _getTimerColor() {
    if (_timeRemaining <= 60) {
      return Colors.red;
    } else if (_timeRemaining <= 300) {
      return Colors.orange;
    }
    return _electricBlue;
  }

  Future<void> _submitEssay() async {
    final essayText = _essayController.text.trim();
    if (essayText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your essay before submitting')),
      );
      return;
    }

    if (_wordCount < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write at least 50 words')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isTimerRunning = false;
    });

    // Navigate to results with essay text
    Navigator.pushReplacementNamed(
      context,
      kRouteEssayResult,
      arguments: EssayResultArgs(
        topic: widget.topic,
        essayText: essayText,
        wordCount: _wordCount,
      ),
    );
  }

  void _confirmSubmit() {
    if (_wordCount < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write at least 50 words before submitting')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Submit Essay?', style: TextStyle(color: kPrimaryText)),
        content: Text(
          'Are you sure you want to submit?\n\n'
          'Word count: $_wordCount / $_targetWordCount\n'
          'Time remaining: ${_formatTime(_timeRemaining)}',
          style: const TextStyle(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitEssay();
            },
            style: TextButton.styleFrom(foregroundColor: kSuccess),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Cancel Essay?', style: TextStyle(color: kPrimaryText)),
        content: const Text(
          'Are you sure you want to cancel?\n\n'
          'Your progress will be lost.',
          style: TextStyle(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Writing', style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _essayController.removeListener(_updateWordCount);
    _essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordProgress = _getWordProgress();
    final timeColor = _getTimerColor();

    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Essay Writing', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _confirmCancel,
        ),
        actions: [
          TextButton(
            onPressed: _confirmSubmit,
            child: const Text('Submit', style: TextStyle(color: Color(0xFF00E5FF))),
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
            // Topic Card
            Container(
              margin: const EdgeInsets.all(kPadL),
              padding: const EdgeInsets.all(kPadL),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(color: kBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOPIC',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: kFontSmall,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.topic,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: kFontBase,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Timer and Word Counter
            Container(
              margin: const EdgeInsets.symmetric(horizontal: kPadL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: timeColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: timeColor),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_timeRemaining),
                          style: TextStyle(
                            color: timeColor,
                            fontSize: kFontBase,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: _electricBlue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, size: 16, color: Color(0xFF00E5FF)),
                        const SizedBox(width: 4),
                        Text(
                          '$_wordCount / $_targetWordCount',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: kFontBase,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Word Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadL),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: wordProgress,
                  backgroundColor: kSurface,
                  color: _electricBlue,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Essay Editor
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: kBorderColor),
                ),
                child: TextFormField(
                  controller: _essayController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: kFontBase,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write your essay here...\n\n'
                        'Tips:\n'
                        '• Start with a strong introduction\n'
                        '• Use paragraphs to organize your thoughts\n'
                        '• Include specific examples\n'
                        '• End with a clear conclusion',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: kFontBase),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            // Tips Banner
            Container(
              margin: const EdgeInsets.fromLTRB(kPadL, 0, kPadL, kPadL),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _electricBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(color: _electricBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF00E5FF), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _wordCount < 50
                          ? 'Write at least 50 words to submit. Target: $_targetWordCount words'
                          : _wordCount >= _targetWordCount
                              ? 'Great! You\'ve reached the target word count!'
                              : '${_targetWordCount - _wordCount} more words to reach target',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: kFontSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}