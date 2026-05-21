import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/notification_provider.dart';
import 'notification_dropdown.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    return Container(
      color: kBackground,
      padding: const EdgeInsets.symmetric(
          horizontal: kPadM, vertical: kPadS),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Flexible(
              child: Image.asset(
                kLogoPath,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'LevelUpHire',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bell icon with badge & Theme Toggle
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showNotifications(context, ref),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: kPrimaryText, size: 26),
                      if (unread > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: kAccentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showNotificationDropdown(context, ref);
  }
}
