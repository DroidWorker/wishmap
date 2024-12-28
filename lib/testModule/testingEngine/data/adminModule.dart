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

class ConclusionByPercent {
  final Map<String, String> conclusionByPercent;

  ConclusionByPercent({required this.conclusionByPercent});

  factory ConclusionByPercent.fromJson(Map<String, dynamic> json) {
    return ConclusionByPercent(
      conclusionByPercent: Map<String, String>.from(json),
    );
  }
}

class FeelingLevel {
  final Map<String, String> feelings;

  FeelingLevel({required this.feelings});

  factory FeelingLevel.fromJson(Map<String, dynamic> json) {
    return FeelingLevel(
      feelings: Map<String, String>.from(json),
    );
  }
}

class SphereData {
  final Map<String, List<String>> combinationQuestions;

  SphereData({required this.combinationQuestions});

  factory SphereData.fromJson(Map<String, dynamic> json) {
    return SphereData(
      combinationQuestions: json.map<String, List<String>>((key, value) {
        return MapEntry(key, List<String>.from(value.map((item) => item.toString())));
      }),
    );
  }
}


class ConclusionCommonInSphere {
  final Map<String, SphereData> spheres;

  ConclusionCommonInSphere({required this.spheres});

  factory ConclusionCommonInSphere.fromJson(Map<String, dynamic> json) {
    return ConclusionCommonInSphere(
      spheres: json.map((k, v) => MapEntry(k, SphereData.fromJson(v))),
    );
  }
}

class MainData {
  final ConclusionByPercent conclusionByPercent;
  final FeelingLevel feelingLevel;
  final ConclusionCommonInSphere conclusionCommonInSphere;

  MainData({
    required this.conclusionByPercent,
    required this.feelingLevel,
    required this.conclusionCommonInSphere,
  });

  factory MainData.fromJson(Map<String, dynamic> json) {
    return MainData(
      conclusionByPercent: ConclusionByPercent.fromJson(json['CONCLUSIONBYPERCENT']),
      feelingLevel: FeelingLevel.fromJson(json['FEELINGLEVEL']),
      conclusionCommonInSphere: ConclusionCommonInSphere.fromJson(json['CONCLUSIONCOMMONINSPHERE']),
    );
  }
}

class EmotionDetail {
  final String score;
  final String perception;
  final Map<String, String> text;

  EmotionDetail({
    required this.score,
    required this.perception,
    required this.text,
  });

  factory EmotionDetail.fromJson(Map<String, dynamic> json) {
    return EmotionDetail(
      score: json['score'],
      perception: json['perseption'],
      text: Map<String, String>.from(json['text']),
    );
  }
}

class EmotionData {
  final Map<String, EmotionDetail> emotions;

  EmotionData({required this.emotions});

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      emotions: json.map((key, value) => MapEntry(key, EmotionDetail.fromJson(value))),
    );
  }
}
