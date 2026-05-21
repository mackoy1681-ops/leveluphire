import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../widgets/floating_bottom_nav.dart';
import '../providers/tab_provider.dart';

// Import all main tab screens
import 'home_screen.dart';
import 'resume_screen.dart';
import 'assessment_screen.dart';
import 'interview_setup.dart';
import 'my_profile_screen.dart';

class MainWrapperScreen extends ConsumerWidget {
  const MainWrapperScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ResumeScreen(),
    AssessmentScreen(),
    InterviewSetup(),
    MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabIndexProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // The IndexedStack keeps all screens alive and preserves their state
          // but only shows the currently selected one instantly.
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),

          // Persistent Bottom Navigation
          FloatingBottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(mainTabIndexProvider.notifier).state = index;
            },
          ),
        ],
      ),
    );
  }
}
