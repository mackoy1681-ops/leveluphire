import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase.dart';
import 'config/theme.dart';
import 'utils/constants.dart';
import 'utils/route_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Path URLs keep browser history in sync with Flutter routes (one back = one screen).
  if (kIsWeb) {
    usePathUrlStrategy();
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
      onGenerateRoute: (settings) =>
          AppRouteGenerator.generate(settings, isSupabaseReady: isSupabaseReady),
    );
  }
}
