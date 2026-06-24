import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase.dart';
import 'config/theme.dart';
import 'utils/constants.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/resume_screen.dart';
import 'screens/resume_editor_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/interview_setup.dart';
import 'screens/my_profile_screen.dart';
import 'screens/discuss_hub.dart';
import 'screens/create_thread_screen.dart';
import 'screens/abstract_test_screen.dart';
import 'screens/numerical_test_screen.dart';
import 'screens/verbal_test_screen.dart';
import 'screens/personality_test_screen.dart';
import 'screens/integrity_test_screen.dart';
import 'screens/essay_setup.dart';
import 'screens/english_proficiency_exam.dart';
import 'screens/civil_service_test_screen.dart';
import 'screens/thread_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Simple performance optimizations for web
  if (kIsWeb) {
    // Disable scroll restoration to prevent navigation issues
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  // Make status bar transparent on Android
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Load .env
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('Dotenv Load Error: $e');
  }

  // Init Supabase
  bool supabaseReady = false;
  try {
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (url != null && key != null && url.isNotEmpty && key.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: key);
      supabaseReady = true;
    }
  } catch (e) {
    debugPrint('Supabase Init Error: $e');
  }

  runApp(
    ProviderScope(
      child: LevelUpHireApp(isSupabaseReady: supabaseReady),
    ),
  );
}

class LevelUpHireApp extends ConsumerWidget {
  final bool isSupabaseReady;
  const LevelUpHireApp({super.key, required this.isSupabaseReady});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LevelUpHire',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      onGenerateRoute: (settings) {
        // Fallback for missing Supabase
        if (!isSupabaseReady && settings.name != kRouteSplash) {
          return MaterialPageRoute(builder: (_) => _ErrorScreen(message: 'Supabase not initialized. Check your .env file.'));
        }

        final name = settings.name ?? '';

        // Deep link support (web refresh should stay on the same page)
        if (name.startsWith('$kRouteThreadPrefix/')) {
          final threadId = name.substring('$kRouteThreadPrefix/'.length);
          if (threadId.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ThreadDetailByIdScreen(threadId: threadId),
            );
          }
        }

        return null;
      },
      routes: {
        kRouteSplash: (_) => SplashScreen(isReady: isSupabaseReady),
        kRouteLogin: (_) => const LoginScreen(),
        kRouteSignup: (_) => const SignupScreen(),
        kRouteProfileSetup: (_) => const ProfileSetupScreen(),
        kRouteHome: (_) => const HomeScreen(),
        kRouteProfile: (_) => const MyProfileScreen(),
        kRouteEditProfile: (_) => const ProfileScreen(),
        kRouteResume: (_) => const ResumeScreen(),
        kRouteResumeEditor: (_) => const ResumeEditorScreen(),
        kRouteAssessment: (_) => const AssessmentScreen(),
        kRouteInterview: (_) => const InterviewSetup(),
        kRouteDiscussHub: (_) => const DiscussHub(),
        kRouteCreateThread: (_) => const CreateThreadScreen(),

        // Assessment sub-pages (so browser back-swipe uses Flutter navigation)
        kRouteAbstractTest: (_) => const AbstractTestScreen(),
        kRouteNumericalTest: (_) => const NumericalTestScreen(),
        kRouteVerbalTest: (_) => const VerbalTestScreen(),
        kRoutePersonalityTest: (_) => const PersonalityTestScreen(),
        kRouteIntegrityTest: (_) => const IntegrityTestScreen(),
        kRouteEssaySetup: (_) => const EssaySetup(),
        kRouteEnglishExam: (_) => const EnglishProficiencyExam(),
        kRouteCivilService: (_) => const CivilServiceTestScreen(),
      },
    );
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
          child: Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
