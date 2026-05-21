import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../models/interview_model.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

// ─── Active Session State ─────────────────────────────────────────────────────

class InterviewSessionState {
  final String field;
  final List<String> questions;
  final List<QAPair> history;
  final int currentIndex;
  final bool isLoadingFeedback;
  final bool isLoadingQuestions;
  final bool isComplete;

  const InterviewSessionState({
    this.field = '',
    this.questions = const [],
    this.history = const [],
    this.currentIndex = 0,
    this.isLoadingFeedback = false,
    this.isLoadingQuestions = false,
    this.isComplete = false,
  });

  InterviewSessionState copyWith({
    String? field,
    List<String>? questions,
    List<QAPair>? history,
    int? currentIndex,
    bool? isLoadingFeedback,
    bool? isLoadingQuestions,
    bool? isComplete,
  }) =>
      InterviewSessionState(
        field: field ?? this.field,
        questions: questions ?? this.questions,
        history: history ?? this.history,
        currentIndex: currentIndex ?? this.currentIndex,
        isLoadingFeedback: isLoadingFeedback ?? this.isLoadingFeedback,
        isLoadingQuestions: isLoadingQuestions ?? this.isLoadingQuestions,
        isComplete: isComplete ?? this.isComplete,
      );

  String? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;
}

class InterviewNotifier extends StateNotifier<InterviewSessionState> {
  InterviewNotifier() : super(const InterviewSessionState());

  final _uuid = const Uuid();

  Future<void> startSession(String field) async {
    state = state.copyWith(
      field: field,
      isLoadingQuestions: true,
      questions: [],
      history: [],
      currentIndex: 0,
      isComplete: false,
    );
    try {
      final questions = await GeminiService.generateInterviewQuestions(
          field: field, count: 6);
      state = state.copyWith(questions: questions, isLoadingQuestions: false);
    } catch (_) {
      state = state.copyWith(isLoadingQuestions: false);
      rethrow;
    }
  }

  Future<QAPair> submitAnswer(String answer) async {
    final question = state.currentQuestion ?? '';
    state = state.copyWith(isLoadingFeedback: true);

    final feedback = await GeminiService.evaluateAnswer(
      question: question,
      answer: answer,
      field: state.field,
    );

    final pair = QAPair(
        question: question, userAnswer: answer, aiFeedback: feedback);
    final newHistory = [...state.history, pair];
    final nextIndex = state.currentIndex + 1;
    final done = nextIndex >= state.questions.length;

    state = state.copyWith(
      history: newHistory,
      currentIndex: nextIndex,
      isLoadingFeedback: false,
      isComplete: done,
    );

    return pair;
  }

  Future<void> saveSession() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    final session = InterviewSession(
      id: '',
      userId: user.id,
      field: state.field,
      history: state.history,
      completedAt: DateTime.now(),
    );
    await SupabaseService.saveInterviewSession(session);
  }

  void reset() => state = const InterviewSessionState();
}

final interviewProvider =
    StateNotifierProvider<InterviewNotifier, InterviewSessionState>(
        (_) => InterviewNotifier());
