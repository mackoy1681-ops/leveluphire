import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/tab_provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../widgets/header.dart';
import '../widgets/floating_bottom_nav.dart';
import '../widgets/action_card.dart';
import 'discuss_hub.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Section ────────────────────────────────
                  profileAsync.when(
                    loading: () => const _ProfileSectionSkeleton(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (profile) {
                      final p = profile ?? UserModel.empty('');
                      return Container(
                        padding: const EdgeInsets.all(kPadL),
                        decoration: const BoxDecoration(
                          color: kBackground,
                          border: Border(
                            bottom: BorderSide(
                                color: kBorderColor, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => ref.read(mainTabIndexProvider.notifier).state = 4,
                              customBorder: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: kSurface,
                                backgroundImage: p.avatarUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        p.avatarUrl)
                                    : null,
                                child: p.avatarUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: kSecondaryText, size: 22)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => ref.read(mainTabIndexProvider.notifier).state = 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.displayName.isEmpty
                                            ? 'Your Name'
                                            : p.displayName,
                                        style: const TextStyle(
                                          inherit: true,
                                          color: kPrimaryText,
                                          fontSize: kFontBase,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (p.username.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          p.username.startsWith('@')
                                              ? p.username
                                              : '@${p.username}',
                                          style: const TextStyle(
                                            color: kAccentBlue,
                                            fontSize: kFontSmall,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, kRouteEditProfile),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              side: const BorderSide(
                                  color: kBorderColor),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                inherit: true,
                                color: kPrimaryText,
                                fontSize: kFontSmall,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                  // ── Section Header ─────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                        kPadL, kPadL, kPadL, kPadS),
                    child: Text(
                      'What would you like to do?',
                      style: TextStyle(
                        color: kSecondaryText,
                        fontSize: kFontSmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // ── Action Cards ───────────────────────────────────
                  ActionCard(
                    title: 'Assessment',
                    description:
                        'Test your knowledge with practice assessments',
                    icon: Icons.assignment_rounded,
                    accentColor: const Color(0xFF9C27B0),
                    onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2,
                  ),
                  ActionCard(
                    title: 'DiscussHub',
                    description:
                        'Ask questions, get answers, and learn from others on the same journey',
                    icon: Icons.forum_rounded,
                    accentColor: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiscussHub()),
                      );
                    },
                  ),
                  ActionCard(
                    title: 'Interview Practice',
                    description:
                        'Practice with AI-generated interview questions',
                    icon: Icons.mic_rounded,
                    accentColor: kSuccess,
                    onTap: () => ref.read(mainTabIndexProvider.notifier).state = 3,
                  ),
                  ActionCard(
                    title: 'My Resume',
                    description:
                        'Build your professional resume with beautiful templates',
                    icon: Icons.description_rounded,
                    accentColor: kAccentBlue,
                    onTap: () => ref.read(mainTabIndexProvider.notifier).state = 1,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionSkeleton extends StatelessWidget {
  const _ProfileSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadL),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, backgroundColor: kSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: kSurface),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
