import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    return SupabaseService.getNotifications(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = AuthService.currentUser;
      if (user == null) return [];
      return SupabaseService.getNotifications(user.id);
    });
  }

  Future<void> markAllRead() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    await SupabaseService.markAllNotificationsRead(user.id);
    state.whenData((list) {
      state = AsyncData(list.map((n) => n.copyWith(isRead: true)).toList());
    });
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(
        NotificationNotifier.new);

// Derived: unread count
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.whenOrNull(
        data: (list) => list.where((n) => !n.isRead).length,
      ) ??
      0;
});
