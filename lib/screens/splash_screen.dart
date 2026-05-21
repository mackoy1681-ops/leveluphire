import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool isReady;
  const SplashScreen({super.key, required this.isReady});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Short beat for branding; long delays feel like a second “page load” after browser refresh.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (!widget.isReady) {
      Navigator.pushReplacementNamed(context, kRouteLogin);
      return;
    }

    // Wait for the first auth emission so web session restore finishes before we read `profiles`.
    await ref.read(authStateProvider.future);
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, kRouteLogin);
      return;
    }

    final profile = await ref.read(userProfileProvider.future);
    if (!mounted) return;

    if (profile == null || !profile.isProfileComplete) {
      Navigator.pushReplacementNamed(context, kRouteProfileSetup);
    } else {
      Navigator.pushReplacementNamed(context, kRouteHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LevelUpHire',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
