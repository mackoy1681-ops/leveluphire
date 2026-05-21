import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'screens/main_wrapper_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/resume_screen.dart';
import 'screens/resume_editor_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/interview_setup.dart';
import 'screens/my_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode (Mobile only, can hang on Web)
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  // Make status bar transparent on Android
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
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
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      initialRoute: kRouteSplash,
      onGenerateRoute: (settings) {
        // Fallback for missing Supabase
        if (!isSupabaseReady && settings.name != kRouteSplash) {
          return MaterialPageRoute(builder: (_) => _ErrorScreen(message: 'Supabase not initialized. Check your .env file.'));
        }
        return null;
      },
      routes: {
        kRouteSplash: (_) => SplashScreen(isReady: isSupabaseReady),
        kRouteLogin: (_) => const LoginScreen(),
        kRouteSignup: (_) => const SignupScreen(),
        kRouteProfileSetup: (_) => const ProfileSetupScreen(),
        kRouteHome: (_) => const MainWrapperScreen(),
        kRouteProfile: (_) => const MyProfileScreen(),
        kRouteEditProfile: (_) => const ProfileScreen(),
        kRouteResume: (_) => const ResumeScreen(),
        kRouteResumeEditor: (_) => const ResumeEditorScreen(),
        kRouteAssessment: (_) => const AssessmentScreen(),
        kRouteInterview: (_) => const InterviewSetup(),
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