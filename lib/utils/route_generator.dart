import 'package:flutter/material.dart';
import '../models/route_args.dart';
import '../screens/abstract_test_screen.dart';
import '../screens/assessment_screen.dart';
import '../screens/civil_service_review.dart';
import '../screens/civil_service_test_screen.dart';
import '../screens/create_thread_screen.dart';
import '../screens/discuss_hub.dart';
import '../screens/english_proficiency_exam.dart';
import '../screens/english_results.dart';
import '../screens/english_review.dart';
import '../screens/essay_result.dart';
import '../screens/essay_setup.dart';
import '../screens/essay_writing.dart';
import '../screens/home_screen.dart';
import '../screens/integrity_test_screen.dart';
import '../screens/interview_screen.dart';
import '../screens/interview_setup.dart';
import '../screens/login_screen.dart';
import '../screens/my_profile_screen.dart';
import '../screens/numerical_test_screen.dart';
import '../screens/personality_test_screen.dart';
import '../screens/print_preview_screen.dart';
import '../screens/professional_exam_screen.dart';
import '../screens/professional_exam_setup.dart';
import '../screens/profile_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/resume_editor_screen.dart';
import '../screens/resume_screen.dart';
import '../screens/resume_view_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/thread_detail_screen.dart';
import '../screens/verbal_test_screen.dart';
import 'constants.dart';

class AppRouteGenerator {
  static Route<dynamic>? generate(
    RouteSettings settings, {
    required bool isSupabaseReady,
  }) {
    if (!isSupabaseReady && settings.name != kRouteSplash) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const _ErrorScreen(
          message: 'Supabase not initialized. Check your .env file.',
        ),
      );
    }

    final name = settings.name ?? '';

    if (name.startsWith('$kRouteThreadPrefix/')) {
      final threadId = name.substring('$kRouteThreadPrefix/'.length);
      if (threadId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ThreadDetailByIdScreen(threadId: threadId),
        );
      }
    }

    switch (name) {
      case kRouteSplash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SplashScreen(isReady: isSupabaseReady),
        );
      case kRouteLogin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case kRouteSignup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignupScreen(),
        );
      case kRouteProfileSetup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileSetupScreen(),
        );
      case kRouteHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case kRouteProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyProfileScreen(),
        );
      case kRouteEditProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case kRouteResume:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResumeScreen(),
        );
      case kRouteResumeEditor:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResumeEditorScreen(),
        );
      case kRouteAssessment:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AssessmentScreen(),
        );
      case kRouteInterview:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InterviewSetup(),
        );
      case kRouteDiscussHub:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DiscussHub(),
        );
      case kRouteCreateThread:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateThreadScreen(),
        );
      case kRouteAbstractTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AbstractTestScreen(),
        );
      case kRouteNumericalTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NumericalTestScreen(),
        );
      case kRouteVerbalTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VerbalTestScreen(),
        );
      case kRoutePersonalityTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PersonalityTestScreen(),
        );
      case kRouteIntegrityTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const IntegrityTestScreen(),
        );
      case kRouteEssaySetup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EssaySetup(),
        );
      case kRouteEnglishExam:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EnglishProficiencyExam(),
        );
      case kRouteCivilService:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CivilServiceTestScreen(),
        );
      case kRouteEssayWriting:
        final topic = settings.arguments as String?;
        if (topic == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EssayWriting(topic: topic),
        );
      case kRouteEssayResult:
        final args = settings.arguments as EssayResultArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EssayResult(
            topic: args.topic,
            essayText: args.essayText,
            wordCount: args.wordCount,
          ),
        );
      case kRouteResumeView:
        final args = settings.arguments as ResumeViewArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResumeViewScreen(
            resume: args.resume,
            isFromMyResumes: args.isFromMyResumes,
          ),
        );
      case kRouteCivilServiceReview:
        final args = settings.arguments as CivilServiceReviewArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CivilServiceReview(
            questions: args.questions,
            userAnswers: args.userAnswers,
            correctAnswers: args.correctAnswers,
            explanations: args.explanations,
            score: args.score,
            totalQuestions: args.totalQuestions,
          ),
        );
      case kRouteEnglishResults:
        final args = settings.arguments as EnglishResultsArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EnglishResults(
            score: args.score,
            totalQuestions: args.totalQuestions,
            percentage: args.percentage,
            passed: args.passed,
            categoryScores: args.categoryScores,
            categoryTotals: args.categoryTotals,
            userAnswersList: args.userAnswersList,
            questions: args.questions,
            correctAnswersList: args.correctAnswersList,
            explanationsList: args.explanationsList,
          ),
        );
      case kRouteEnglishReview:
        final args = settings.arguments as EnglishReviewArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EnglishReview(
            userAnswersList: args.userAnswersList,
            questions: args.questions,
            correctAnswersList: args.correctAnswersList,
            explanationsList: args.explanationsList,
          ),
        );
      case kRoutePrintPreview:
        final args = settings.arguments as PrintPreviewArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PrintPreviewScreen(
            resume: args.resume,
            selectedTemplateId: args.selectedTemplateId,
          ),
        );
      case kRouteProfessionalExamLoading:
        final profession = settings.arguments as String?;
        if (profession == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProfessionalExamLoading(profession: profession),
        );
      case kRouteProfessionalExam:
        final args = settings.arguments as ProfessionalExamArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProfessionalExamScreen(
            profession: args.profession,
            questions: args.questions,
          ),
        );
      case kRouteInterviewSession:
        final args = settings.arguments as InterviewSessionArgs?;
        if (args == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => InterviewScreen(
            profession: args.profession,
            isFemale: args.isFemale,
            imageFileName: args.imageFileName,
          ),
        );
      default:
        return null;
    }
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
