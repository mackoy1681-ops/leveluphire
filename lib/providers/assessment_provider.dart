import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../models/assessment_model.dart';
import '../services/auth_service.dart';

// ─── Assessment Questions ─────────────────────────────────────────────────────

class AssessmentQuestionsNotifier
    extends AsyncNotifier<List<AssessmentQuestion>> {
  @override
  Future<List<AssessmentQuestion>> build() async => [];

  Future<void> generate(String topic) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => GeminiService.generateAssessmentQuestions(topic: topic));
  }

  void reset() {
    state = const AsyncData([]);
  }
}

final assessmentQuestionsProvider = AsyncNotifierProvider<
    AssessmentQuestionsNotifier,
    List<AssessmentQuestion>>(AssessmentQuestionsNotifier.new);

// ─── Assessment History ───────────────────────────────────────────────────────

class AssessmentHistoryNotifier
    extends AsyncNotifier<List<AssessmentResult>> {
  @override
  Future<List<AssessmentResult>> build() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    return SupabaseService.getAssessmentHistory(user.id);
  }

  Future<void> saveResult(AssessmentResult result) async {
    await SupabaseService.saveAssessmentResult(result);
    // Prepend optimistically
    state.whenData((list) {
      state = AsyncData([result, ...list]);
    });
  }
}

final assessmentHistoryProvider =
    AsyncNotifierProvider<AssessmentHistoryNotifier, List<AssessmentResult>>(
        AssessmentHistoryNotifier.new);
