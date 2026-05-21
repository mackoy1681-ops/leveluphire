import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/notification_provider.dart';
import 'notification_dropdown.dart';

class NotificationBar extends ConsumerWidget {
  const NotificationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    return GestureDetector(
      onTap: () => showNotificationDropdown(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: kPadL, vertical: 8),
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(
            bottom: BorderSide(color: kBorderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              unread > 0
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: unread > 0 ? kAccentBlue : kSecondaryText,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              unread > 0
                  ? '$unread unread notification${unread == 1 ? '' : 's'}'
                  : 'No new notifications',
              style: TextStyle(
                color: unread > 0 ? kAccentBlue : kSecondaryText,
                fontSize: kFontSmall,
                fontWeight:
                    unread > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: unread > 0 ? kAccentBlue : kSecondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
