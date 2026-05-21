import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

void showNotificationDropdown(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(ctx),
        child: const _NotificationSheet(),
      ),
    ),
  );
}

class _NotificationSheet extends ConsumerWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, scrollController) => GestureDetector(
        onTap: () {}, // Prevent closing when tapping inside the sheet
        child: Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kPadL, vertical: kPadS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: kFontHeading,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(notificationProvider.notifier)
                          .markAllRead(),
                      child: const Text('Mark all read',
                          style: TextStyle(color: kAccentBlue)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: kBorderColor),

              // List
              Expanded(
                child: notificationsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: kAccentBlue)),
                  error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: kError))),
                  data: (notifications) => notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No new notifications',
                            style: TextStyle(color: kSecondaryText),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: kBorderColor),
                          itemBuilder: (_, i) =>
                              _NotificationTile(notifications[i], ref),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final WidgetRef ref;

  const _NotificationTile(this.notification, this.ref);

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTime(notification.createdAt);
    return Container(
      color: notification.isRead ? Colors.transparent : kAccentBlue.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(
          horizontal: kPadL, vertical: kPadM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: notification.isRead
                  ? Colors.transparent
                  : kAccentBlue,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    color: kPrimaryText,
                    fontSize: kFontBase,
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(timeAgo,
                    style: const TextStyle(
                        color: kSecondaryText, fontSize: kFontSmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
