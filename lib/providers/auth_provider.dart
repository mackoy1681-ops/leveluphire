import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

// ─── Raw Auth State Stream ────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateStream;
});

// ─── Current Supabase User ────────────────────────────────────────────────────

final currentUserProvider = Provider<User?>((ref) {
  return AuthService.currentUser;
});

// ─── User Profile ─────────────────────────────────────────────────────────────

class UserProfileNotifier extends AsyncNotifier<UserModel?> {
  /// Resolves once Supabase has emitted auth state (session restore on web, etc.).
  static String? _userIdFromAuth(AsyncValue<AuthState> async) {
    return async.when(
      data: (state) =>
          state.session?.user.id ?? AuthService.currentUser?.id,
      loading: () => AuthService.currentUser?.id,
      error: (_, __) => AuthService.currentUser?.id,
    );
  }

  @override
  Future<UserModel?> build() async {
    // Auth stream can emit multiple times on web (restore + refresh). Watching only
    // the stable user id avoids refetching the profile and a second loading flicker.
    final userId = ref.watch(
      authStateProvider.select(_userIdFromAuth),
    );
    if (userId == null) return null;
    return SupabaseService.getUserProfile(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = _userIdFromAuth(ref.read(authStateProvider));
      if (userId == null) return null;
      return SupabaseService.getUserProfile(userId);
    });
  }

  Future<void> updateProfile(UserModel updated) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final row = await SupabaseService.commitUserProfile(updated);
      debugPrint('Profile successfully updated in Supabase');
      return UserModel.fromMap(row);
    });
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel?>(
        UserProfileNotifier.new);
