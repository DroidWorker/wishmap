import 'package:flutter/cupertino.dart';

import '../../repository/local_repository.dart';
import 'data/adminModule.dart';
import 'data/models.dart';
import 'testingRepository.dart';

class TestViewModel extends ChangeNotifier {
  final repository = TestingRepository();
  LocalRepository localRep = LocalRepository();
  bool isInLoading = false;

  init() async {
    hokinsKoefs = await repository.getHokins();
  }

  List<Question> questionsAndKoeffs = [];
  String moduleName = "";

  //test1
  List<double> ansversM1 = [];
  Map<String, List<List<List<double>>>> hokinsKoefs = {};
  Map<String, double> resultM1 = {};
  Map<String, double> hokinsResultM1 = {};

  Future getmoduleName() async {
    moduleName = await repository.getmoduleName();
  }

  Future getQuestions() async {
    questionsAndKoeffs = await repository.getQuestions(1);
    notifyListeners();
  }

  Future getHokinsKoefs() async {
    hokinsKoefs = await repository.getHokins();
    notifyListeners();
  }

  Future calculateResult() async {
    final answerWeights = [1, 0.75, 0.5, 0.25, 0];
    List<CalculationStep> steps = [];
    if (questionsAndKoeffs.length == ansversM1.length) {
      List<double> result = [0, 0, 0, 0, 0, 0, 0, 0];
      Map<String, List<double>> hokinsResult = Map.fromEntries(
        hokinsKoefs.keys.map((element) {
          return MapEntry(element, List<double>.filled(16, 0));
        }),
      );
      for (var (i, koeff) in ansversM1.indexed) {
        List<double> intermediateValue = [];
        for (var (j, value) in questionsAndKoeffs[i].indexes.indexed) {
          result[j] += value * koeff;
          intermediateValue.add(value * koeff);
        }
        for (var sphere in hokinsKoefs.keys) {
          for (var (k, element) in hokinsKoefs[sphere]![i].indexed) {
            hokinsResult[sphere]?[k] += element[answerWeights.indexOf(koeff)];
          }
        }
        steps.add(CalculationStep(
          question: questionsAndKoeffs[i].question,
          weights: questionsAndKoeffs[i].indexes,
          coefficient: koeff,
          result: List<double>.from(result),
          hokinsStep: hokinsKoefs.map((k,v) =>
              MapEntry(k, v[i].map((e)=> e[answerWeights.indexOf(koeff)]).toList())),
          hokinsResult: hokinsResult.map((key, value) =>
              MapEntry(key, List<double>.from(value))),
          intermediateValue: List<double>.from(intermediateValue),
        ));
      }
        localRep.saveCalculation(steps);
      resultM1["Здоровье"] = result[0];
      resultM1["Отношения"] = result[1];
      resultM1["Окружение"] = result[2];
      resultM1["Призвание"] = result[3];
      resultM1["Богатство"] = result[4];
      resultM1["Саморазвитие"] = result[5];
      resultM1["Яркость жизни"] = result[6];
      resultM1["Духовность"] = result[7];

      for (var (i, element) in hokinsResult.values.first.indexed) {
        hokinsResult.values.first[i] = element / 100;
      }
      hokinsResultM1["Стыд"] = hokinsResult.values.last[0];
      hokinsResultM1["Вина"] = hokinsResult.values.last[1];
      hokinsResultM1["Апатия"] = hokinsResult.values.last[2];
      hokinsResultM1["Горе"] = hokinsResult.values.last[3];
      hokinsResultM1["Страх"] = hokinsResult.values.last[4];
      hokinsResultM1["Жажда"] = hokinsResult.values.last[5];
      hokinsResultM1["Гнев"] = hokinsResult.values.last[6];
      hokinsResultM1["Гордыня"] = hokinsResult.values.last[7];
      hokinsResultM1["Смелость"] = hokinsResult.values.last[8];
      hokinsResultM1["Нейтралитет"] = hokinsResult.values.last[9];
      hokinsResultM1["Готовность"] = hokinsResult.values.last[10];
      hokinsResultM1["Принятие"] = hokinsResult.values.last[11];
      hokinsResultM1["Разум"] = hokinsResult.values.last[12];
      hokinsResultM1["Любовь"] = hokinsResult.values.last[13];
      hokinsResultM1["Гармония"] = hokinsResult.values.last[14];
      //hokinsResultM1["Покой"] = hokinsResult.values.first[15];

      notifyListeners();
    }
  }

  List<List<double>> getHokinsForQuestion(int qNumber) {
    return hokinsKoefs.values.first[qNumber];
  }
}
