import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/resume_model.dart';
import '../services/auth_service.dart';

// ─── Resume List ──────────────────────────────────────────────────────────────

class ResumeListNotifier extends AsyncNotifier<List<ResumeModel>> {
  @override
  Future<List<ResumeModel>> build() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    return SupabaseService.getResumes(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = AuthService.currentUser;
      if (user == null) return [];
      return SupabaseService.getResumes(user.id);
    });
  }

  Future<ResumeModel> save(ResumeModel resume) async {
    final saved = await SupabaseService.saveResume(resume);
    await refresh();
    return saved;
  }

  Future<void> delete(String resumeId) async {
    await SupabaseService.deleteResume(resumeId);
    state.whenData((list) {
      state = AsyncData(list.where((r) => r.id != resumeId).toList());
    });
  }
}

final resumeListProvider =
    AsyncNotifierProvider<ResumeListNotifier, List<ResumeModel>>(
        ResumeListNotifier.new);

// ─── Current Resume Being Edited ──────────────────────────────────────────────

final currentResumeProvider =
    StateProvider<ResumeModel?>((ref) => null);
