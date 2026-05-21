import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class InterviewSummary extends StatefulWidget {
  final String profession;
  final int score;
  final int totalQuestions;
  final int percentage;
  final List<String> questions;
  final List<String> userAnswers;
  final List<String> feedback;
  final String? aiSummary;

  const InterviewSummary({
    super.key,
    required this.profession,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.questions,
    required this.userAnswers,
    required this.feedback,
    this.aiSummary,
  });

  @override
  State<InterviewSummary> createState() => _InterviewSummaryState();
}

class _InterviewSummaryState extends State<InterviewSummary> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _saveToDatabase();
  }

  Future<void> _saveToDatabase() async {
    setState(() => _isSaving = true);
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Save to interview_results
      await Supabase.instance.client.from('interview_results').insert({
        'id': const Uuid().v4(),
        'user_id': user.id,
        'profession': widget.profession,
        'score': widget.score,
        'total_questions': widget.totalQuestions,
        'percentage': widget.percentage,
        'summary': widget.aiSummary,
        'taken_at': DateTime.now().toIso8601String(),
      });

      // Save award to user_awards (icon #7)
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
          'score': widget.score,
          'total_questions': widget.totalQuestions,
          'percentage': widget.percentage,
          'award_level': 'taken',
          'taken_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving interview result: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.percentage >= 60;
    
    return Dialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Container(
        padding: const EdgeInsets.all(kPadL),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: passed ? kSuccess.withOpacity(0.1) : kError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.verified : Icons.school,
                size: 48,
                color: passed ? kSuccess : kError,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              passed ? 'Interview Complete!' : 'Interview Completed',
              style: const TextStyle(
                color: kPrimaryText,
                fontSize: kFontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Score
            Text(
              '${widget.percentage}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: passed ? kSuccess : kError,
              ),
            ),
            Text(
              '${widget.score} out of ${widget.totalQuestions} answered well',
              style: const TextStyle(
                color: kSecondaryText,
                fontSize: kFontBase,
              ),
            ),
            const SizedBox(height: 24),
            
            // Summary
            if (widget.aiSummary != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(kRadiusCard),
                  border: Border.all(color: kBorderColor),
                ),
                child: Text(
                  widget.aiSummary!,
                  style: const TextStyle(
                    color: kPrimaryText,
                    fontSize: kFontBase,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
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
                    : const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}