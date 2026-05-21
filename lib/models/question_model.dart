class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String difficulty;
  final String category;
  final String? explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.difficulty,
    this.category = '',
    this.explanation,
  });
}