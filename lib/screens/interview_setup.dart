import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/tab_provider.dart';
import 'interview_incoming.dart';

class InterviewSetup extends ConsumerStatefulWidget {
  const InterviewSetup({super.key});

  @override
  ConsumerState<InterviewSetup> createState() => _InterviewSetupState();
}

class _InterviewSetupState extends ConsumerState<InterviewSetup> {
  final TextEditingController _professionController = TextEditingController();
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    'Software Engineer',
    'Nurse',
    'Lawyer',
    'Accountant',
    'Teacher',
    'Marketing Manager',
    'Project Manager',
    'Data Analyst',
    'Graphic Designer',
    'Sales Representative',
  ];

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
  }

  void _continue() async {
    final profession = _professionController.text.trim();
    if (profession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your profession or field')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);
      
      final random = Random();
      final isFemale = random.nextBool();
      
      String imageFileName;
      if (isFemale) {
        final index = random.nextInt(12) + 1;
        imageFileName = 'female${index.toString().padLeft(2, '0')}.jpeg';
      } else {
        final index = random.nextInt(4) + 1;
        imageFileName = 'male${index.toString().padLeft(2, '0')}.jpeg';
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => InterviewIncoming(
          profession: profession,
          isFemale: isFemale,
          imageFileName: imageFileName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Interview Practice', style: TextStyle(color: kPrimaryText)),
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          tooltip: 'Back to Home',
          onPressed: () => ref.read(mainTabIndexProvider.notifier).state = 0,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Practice Interview',
              style: TextStyle(
                color: kPrimaryText,
                fontSize: kFontHeading,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get interviewed based on your profession and receive feedback on your strengths and weaknesses',
              style: TextStyle(
                color: kSecondaryText,
                fontSize: kFontBase,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Your profession or field',
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
                hintText: 'e.g. Software Engineer, Nurse, Lawyer, Accountant',
                hintStyle: const TextStyle(color: kSecondaryText, fontSize: 12),
                filled: true,
                fillColor: kSurface,
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
            const SizedBox(height: 16),

            const Text(
              'Quick suggestions:',
              style: TextStyle(
                color: kSecondaryText,
                fontSize: kFontSmall,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickSuggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _professionController.text = suggestion;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontSmall,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}