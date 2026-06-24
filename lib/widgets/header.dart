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
      color: kSurface,
      padding: const EdgeInsets.symmetric(
          horizontal: kPadM, vertical: kPadS),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: kSurface,
            border: const Border(
              bottom: BorderSide(color: kBorderColor, width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showNotifications(context, ref),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: kBorderColor),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: kPrimaryText, size: 22),
                        ),
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
