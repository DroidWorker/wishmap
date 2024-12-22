class CalculationStep {
  final String question;
  final List<double> weights;
  final double coefficient;
  final List<double> result;
  final Map<String, List<double>> hokinsStep;
  final Map<String, List<double>> hokinsResult;
  final List<double> intermediateValue;

  CalculationStep({
    required this.question,
    required this.weights,
    required this.coefficient,
    required this.result,
    required this.hokinsStep,
    required this.hokinsResult,
    required this.intermediateValue,
  });

  Map<String, dynamic> toJson() =>
      {
        'question': question,
        'weights': weights,
        'coefficient': coefficient,
        'result': result,
        "hokinsStep": hokinsStep,
        'hokinsResult': hokinsResult,
        'intermediateValue': intermediateValue,
      };

  factory CalculationStep.fromJson(Map<String, dynamic> json) {
    return CalculationStep(
      question: json['question'],
      weights: List<double>.from(json['weights']),
      coefficient: json['coefficient'],
      result: List<double>.from(json['result']),
      hokinsStep: (json['hokinsStep'] as Map<String, dynamic>).map((k, v) =>
          MapEntry(k, List<double>.from(v))),
      hokinsResult: (json['hokinsResult'] as Map<String, dynamic>).map((k, v) =>
          MapEntry(k, List<double>.from(v))),
      intermediateValue: List<double>.from(json['intermediateValue']),
    );
  }
}