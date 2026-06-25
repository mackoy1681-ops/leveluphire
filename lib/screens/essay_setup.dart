import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EssaySetup extends StatefulWidget {
  const EssaySetup({super.key});

  @override
  State<EssaySetup> createState() => _EssaySetupState();
}

class _EssaySetupState extends State<EssaySetup> {
  final Random _random = Random();
  
  final Color _deepSpace = const Color(0xFF0B0C10);
  final Color _nebulaBlue = const Color(0xFF1F2833);
  final Color _electricBlue = const Color(0xFF00E5FF);
  
  // 30 predefined essay topics
  final List<String> _topics = [
    'Why are you the best candidate for this position?',
    'Describe a challenge you overcame at work.',
    'What does leadership mean to you?',
    'Where do you see yourself in 5 years?',
    'How do you handle pressure and deadlines?',
    'What is your greatest strength?',
    'Describe a time you worked in a team.',
    'Why did you choose your profession?',
    'How do you stay motivated at work?',
    'What is your approach to problem-solving?',
    'Describe a failure and what you learned.',
    'How do you handle criticism?',
    'What makes a good coworker?',
    'How do you prioritize tasks?',
    'Describe your ideal work environment.',
    'What skills do you want to improve?',
    'How do you handle conflicts at work?',
    'Why is teamwork important?',
    'Describe a time you showed initiative.',
    'What does work-life balance mean to you?',
    'How do you adapt to change?',
    'What motivates you to succeed?',
    'Describe a time you helped a coworker.',
    'How do you celebrate achievements?',
    'What is your approach to learning new things?',
    'Describe your career dream.',
    'How do you handle difficult customers?',
    'What does integrity mean at work?',
    'How do you stay organized?',
    'Why do you want to grow in your field?',
  ];

  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _selectRandomTopic();
  }

  void _selectRandomTopic() {
    final randomIndex = _random.nextInt(_topics.length);
    setState(() {
      _selectedTopic = _topics[randomIndex];
    });
  }

  void _startEssay() {
    if (_selectedTopic == null) return;
    
    Navigator.pushNamed(
      context,
      kRouteEssayWriting,
      arguments: _selectedTopic!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        title: const Text('Essay Writing Assessment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Essay Writing Assessment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kFontHeading,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demonstrate your writing skills and get AI-powered feedback',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: kFontBase,
                ),
              ),
              const SizedBox(height: 32),

              // Grading Criteria Card
              Container(
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
                      'GRADING CRITERIA (AI Evaluated)',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: kFontSmall,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCriteriaRow('Content', '30%', 'Relevance, depth, accuracy'),
                    const SizedBox(height: 12),
                    _buildCriteriaRow('Structure', '25%', 'Introduction, body, conclusion, flow'),
                    const SizedBox(height: 12),
                    _buildCriteriaRow('Grammar', '20%', 'Spelling, punctuation, sentence structure'),
                    const SizedBox(height: 12),
                    _buildCriteriaRow('Clarity', '15%', 'Readability, conciseness'),
                    const SizedBox(height: 12),
                    _buildCriteriaRow('Creativity', '10%', 'Originality, engaging writing'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rules Card
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: _electricBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Time limit: 30 minutes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: kFontBase,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.description, color: _electricBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Word count: 250 words',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: kFontBase,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: _electricBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Score ≥ 76% to earn a badge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: kFontBase,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your Topic Card
              Container(
                padding: const EdgeInsets.all(kPadL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _electricBlue.withOpacity(0.1),
                      _deepSpace,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: _electricBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR TOPIC',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: kFontSmall,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedTopic ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: kFontTitle,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _selectRandomTopic,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _electricBlue,
                        side: BorderSide(color: _electricBlue),
                      ),
                      child: const Text('Randomize Topic'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startEssay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricBlue,
                    foregroundColor: _deepSpace,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                  child: const Text(
                    'Start Essay',
                    style: TextStyle(
                      fontSize: kFontBase,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String category, String weight, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: kFontSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 45,
          child: Text(
            weight,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: kFontSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: kFontSmall,
            ),
          ),
        ),
      ],
    );
  }
}