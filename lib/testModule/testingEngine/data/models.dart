class Question {
  String question;
  final List<String> answers;
  final List<double> indexes;

  Question(
      {required this.question, required this.answers, required this.indexes});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      indexes: List<double>.from(json['indexes']),
    );
  }
}