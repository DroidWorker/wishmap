import 'dart:ffi';

class Question {
  String question;
  final List<String> answers;
  final List<double> indexes;

  Question(
      {required this.question, required this.answers, required this.indexes});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: ["Да", "Скорее да", "Что-то среднее", "Скорее нет", "Нет"],
      indexes: List<double>.from(json['indexes'])
    );
  }
}