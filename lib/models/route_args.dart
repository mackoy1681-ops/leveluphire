import 'question_model.dart';
import 'resume_model.dart';

class EssayResultArgs {
  final String topic;
  final String essayText;
  final int wordCount;

  const EssayResultArgs({
    required this.topic,
    required this.essayText,
    required this.wordCount,
  });
}

class ResumeViewArgs {
  final ResumeModel resume;
  final bool isFromMyResumes;

  const ResumeViewArgs({
    required this.resume,
    this.isFromMyResumes = false,
  });
}

class CivilServiceReviewArgs {
  final List<Question> questions;
  final List<int> userAnswers;
  final List<int> correctAnswers;
  final List<String> explanations;
  final int score;
  final int totalQuestions;

  const CivilServiceReviewArgs({
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
    required this.explanations,
    required this.score,
    required this.totalQuestions,
  });
}

class EnglishResultsArgs {
  final int score;
  final int totalQuestions;
  final int percentage;
  final bool passed;
  final Map<String, int> categoryScores;
  final Map<String, int> categoryTotals;
  final List<Map<String, dynamic>> userAnswersList;
  final List<Question> questions;
  final List<Map<String, dynamic>> correctAnswersList;
  final List<String> explanationsList;

  const EnglishResultsArgs({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.categoryScores,
    required this.categoryTotals,
    required this.userAnswersList,
    required this.questions,
    required this.correctAnswersList,
    required this.explanationsList,
  });
}

class EnglishReviewArgs {
  final List<Map<String, dynamic>> userAnswersList;
  final List<Question> questions;
  final List<Map<String, dynamic>> correctAnswersList;
  final List<String> explanationsList;

  const EnglishReviewArgs({
    required this.userAnswersList,
    required this.questions,
    required this.correctAnswersList,
    required this.explanationsList,
  });
}

class PrintPreviewArgs {
  final ResumeModel resume;
  final String selectedTemplateId;

  const PrintPreviewArgs({
    required this.resume,
    required this.selectedTemplateId,
  });
}

class ProfessionalExamArgs {
  final String profession;
  final List<Question> questions;

  const ProfessionalExamArgs({
    required this.profession,
    required this.questions,
  });
}

class InterviewSessionArgs {
  final String profession;
  final bool isFemale;
  final String imageFileName;

  const InterviewSessionArgs({
    required this.profession,
    required this.isFemale,
    required this.imageFileName,
  });
}
