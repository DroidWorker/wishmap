import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../repository/local_repository.dart';
import 'data/adminModule.dart';
import 'data/models.dart';
import 'testingRepository.dart';

class TestViewModel extends ChangeNotifier {
  var kinClicked = false;
  final repository = TestingRepository();
  LocalRepository localRep = LocalRepository();
  bool isInLoading = false;
  int avg = 0;
  var step = 1;

  init() async {
    hokinsKoefs = await repository.getHokins();
    mainData = await getMainReportData();
    configEmotionSphere = await getHokinsSphere("Красота и здоровье");
  }

  List<Question> questionsAndKoeffs = [];
  String moduleName = "";

  //test1
  List<double> ansversM1 = [];
  Map<String, List<List<List<double>>>> hokinsKoefs = {};
  MainData? mainData;
  EmotionData? configEmotionSphere;
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
    step = 1;
    localRep.setTestPassed();
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
          hokinsStep: hokinsKoefs.map((k, v) =>
              MapEntry(k,
                  v[i].map((e) => e[answerWeights.indexOf(koeff)]).toList())),
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

  String buildStringByAnswers(String sphere) {
    //mainData
    var result = "";
    var combinationIndex = -1;

    final textsData = mainData?.conclusionCommonInSphere.spheres[sphere];

    textsData?.combinationQuestions.entries.forEach((e) {
      if (e.key == "COMBINATIONQUESTIONS" || e.key == "COMBINATION") {
        if (e.key == "COMBINATIONQUESTIONS") {
          final answers = e.value.map((e) {
            return double.parse(e);
          }).toList();
          combinationIndex = getCombinationIndex(answers);
        }
        else {
          if (combinationIndex != -1 && combinationIndex < e.value.length) {
            result += e.value.elementAt(combinationIndex);
          }
        }
      } else {
        result = e.value[ansversM1[int.parse(e.key)].toInt()];
      }
    });
    return result;
  }

  Future<MainData> getMainReportData() async {
    String jsonString = await rootBundle.loadString(
        'assets/res/config_texts.json');
    Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    MainData mainData = MainData.fromJson(jsonResponse);
    return mainData;
  }

  Future<EmotionData> getHokinsSphere(String sphere) async {
    String jsonString = await loadJsonString(sphere);
    Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    EmotionData emotionData = EmotionData.fromJson(jsonResponse);
    return emotionData;
  }

  int getCombinationIndex(List<double> combination) {
    List<double> possibleValues = [0, 0.25, 0.5, 0.75, 1];
    int base = possibleValues.length;
    int index = 0;
    for (int i = 0; i < combination.length; i++) {
      int position = possibleValues.indexOf(combination[i]);
      if (position == -1) {
        return -1;
      }
      index = index * base + position;
    }
    return index;
  }

  void buildConfigAsync(String sphere) async {
    configEmotionSphere = await getHokinsSphere(sphere);
  }

  Future<String> loadJsonString(String sphere) async {
    switch (sphere) {
      case "Красота и здоровье":
        return await rootBundle.loadString(
            'assets/res/config_hokins_beautyhealth_w.json');
      case "Отношения и любовь":
        return await rootBundle.loadString(
            'assets/res/config_hokins_love_w.json');
      case "Призвание и карьера":
        return await rootBundle.loadString(
            'assets/res/config_hokins_relationships_w.json');
      case "Твое окружение":
        return await rootBundle.loadString(
            'assets/res/config_hokins_ikigai_w.json');
      case "Богатство и деньги":
        return await rootBundle.loadString(
            'assets/res/config_hokins_finance_w.json');
      case "Яркость жизни":
        return await rootBundle.loadString(
            'assets/res/config_hokins_highlife_w.json');
      case "Самосознание":
        return await rootBundle.loadString(
            'assets/res/config_hokins_selfmade_w.json');
      default:
        throw Exception('Неизвестная сфера: $sphere');
    }
  }

  List<List<double>> getHokinsForQuestion(int qNumber) {
    return hokinsKoefs.values.first[qNumber];
  }
}
