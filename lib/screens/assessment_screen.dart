import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assessment_model.dart';
import '../providers/assessment_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../providers/tab_provider.dart';

// Test Screen Imports
import 'abstract_test_screen.dart';
import 'numerical_test_screen.dart';
import 'verbal_test_screen.dart';
import 'personality_test_screen.dart';
import 'integrity_test_screen.dart';
import 'professional_exam_setup.dart';
import 'interview_setup.dart';
import 'essay_setup.dart';
import 'english_proficiency_exam.dart';
import 'civil_service_test_screen.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  String? _profilePhotoUrl;

  final Color _pageBackground = kBackground;
  final Color _panelSurface = kSurface;
  final Color _softBlue = const Color(0xFFE8F3FF);
  final Color _electricBlue = kAccentBlue;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      
      if (response != null && mounted) {
        setState(() {
          _profilePhotoUrl = response['avatar_url'] as String?;
        });
      }
    }
  }

  void _startAssessment(String testName, String category) {
    if (testName == 'Abstract Reasoning') {
      Navigator.pushNamed(context, kRouteAbstractTest);
    } else if (testName == 'Numerical Reasoning') {
      Navigator.pushNamed(context, kRouteNumericalTest);
    } else if (testName == 'Verbal Reasoning') {
      Navigator.pushNamed(context, kRouteVerbalTest);
    } else if (testName == 'Work Personality Profile') {
      Navigator.pushNamed(context, kRoutePersonalityTest);
    } else if (testName == 'Integrity & Work Habits') {
      Navigator.pushNamed(context, kRouteIntegrityTest);
    } else if (testName == 'Interview Practice') {
      Navigator.pushNamed(context, kRouteInterview);
    } else if (testName == 'Essay Writing') {
      Navigator.pushNamed(context, kRouteEssaySetup);
    } else if (testName == 'English Proficiency Exam') {
      Navigator.pushNamed(context, kRouteEnglishExam);
    } else if (testName == 'Civil Service Exam') {
      Navigator.pushNamed(context, kRouteCivilService);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting $testName assessment...')),
      );
    }
  }

  void _showProfessionalExamPopup() {
    showDialog(
      context: context,
      builder: (_) => const ProfessionalExamSetup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Assessments', style: TextStyle(color: kPrimaryText)),
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          tooltip: 'Back to Home',
          onPressed: () {
            // If this screen was pushed as a route (web/mobile), pop it.
            // Otherwise fall back to switching the main tab.
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              ref.read(mainTabIndexProvider.notifier).state = 0;
            }
          },
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, kRouteProfile),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _softBlue,
                backgroundImage: _profilePhotoUrl != null
                    ? CachedNetworkImageProvider(_profilePhotoUrl!)
                    : null,
                child: _profilePhotoUrl == null
                    ? const Icon(Icons.person, size: 18, color: kSecondaryText)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _pageBackground,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(kPadL, kPadL, kPadL, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Level Up Your Skills',
                style: TextStyle(
                  color: kPrimaryText,
                  fontSize: kFontHeading,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete assessments to identify strengths and areas for improvement',
                style: TextStyle(
                  color: kSecondaryText,
                  fontSize: kFontBase,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 18, color: _electricBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Take a test, earn a badge',
                      style: TextStyle(
                        color: _electricBlue,
                        fontSize: kFontSmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // COGNITIVE TESTS
              _buildCategoryHeader('Cognitive Tests'),
              const SizedBox(height: 12),
              _buildAssessmentCardWithSmallButton(
                title: 'Abstract Reasoning',
                description: 'Measures your ability to identify patterns, logical rules, and trends in abstract shapes.',
                onTap: () => _startAssessment('Abstract Reasoning', 'cognitive'),
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'Numerical Reasoning',
                description: 'Tests your ability to work with numbers, percentages, ratios, and data interpretation.',
                onTap: () => _startAssessment('Numerical Reasoning', 'cognitive'),
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'Verbal Reasoning',
                description: 'Assesses reading comprehension, critical thinking, and logical deduction from text.',
                onTap: () => _startAssessment('Verbal Reasoning', 'cognitive'),
              ),
              const SizedBox(height: 24),

              // PERSONALITY & BEHAVIORAL
              _buildCategoryHeader('Personality & Behavioral'),
              const SizedBox(height: 12),
              _buildAssessmentCardWithSmallButton(
                title: 'Work Personality Profile',
                description: 'Discover your work style, leadership approach, and how you collaborate with others in a professional environment.',
                onTap: () => _startAssessment('Work Personality Profile', 'personality'),
              ),
              const SizedBox(height: 24),

              // WORK ETHICS & INTEGRITY
              _buildCategoryHeader('Work Ethics & Integrity'),
              const SizedBox(height: 12),
              _buildAssessmentCardWithSmallButton(
                title: 'Integrity & Work Habits',
                description: 'Assess your work ethics, integrity, self-discipline, accountability, reliability, and professionalism in the workplace.',
                onTap: () => _startAssessment('Integrity & Work Habits', 'integrity'),
              ),
              const SizedBox(height: 24),

              // LEVELUPHIRE TEST
              _buildCategoryHeader('LevelUpHire Test'),
              const SizedBox(height: 12),
              _buildAssessmentCardWithSmallButton(
                title: 'Professional Exam',
                description: 'Take the ultimate challenge designed for experienced professionals',
                onTap: _showProfessionalExamPopup,
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'English Proficiency Exam',
                description: 'Measure your English communication skills for BPO and corporate roles. Passing score is 76%.',
                onTap: () => _startAssessment('English Proficiency Exam', 'english'),
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'Civil Service Exam',
                description: 'Prepare for the Philippine Civil Service Exam with 40 questions covering numerical, verbal, and logical reasoning.',
                onTap: () => _startAssessment('Civil Service Exam', 'civil'),
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'Interview Practice',
                description: 'Practice common questions, behavioral interviews using the STAR method, and technical interview scenarios.',
                onTap: () => _startAssessment('Interview Practice', 'interview'),
              ),
              _buildAssessmentCardWithSmallButton(
                title: 'Essay Writing',
                description: 'Write a well-structured essay and receive AI-powered feedback on your writing skills.',
                onTap: () => _startAssessment('Essay Writing', 'essay'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _electricBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryText,
              fontSize: kFontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCardWithSmallButton({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: kPrimaryText,
                          fontSize: kFontBase,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _electricBlue,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Take Test',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: kSecondaryText,
                    fontSize: kFontSmall,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
