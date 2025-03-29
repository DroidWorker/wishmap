import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../repository/Repository.dart';
import '../../repository/local_repository.dart';
import 'data/adminModule.dart';
import 'data/models.dart';
import 'testingRepository.dart';

class TestViewModel extends ChangeNotifier {
  var kinClicked = false;
  final repository = TestingRepository();
  Repository firepository = Repository();
  LocalRepository localRep = LocalRepository();
  bool isInLoading = false;
  int avg = 0;
  var step = 1;
  final spheres = [
    "Красота и здоровье",
    "Отношения и любовь",
    "Твое окружение",
    "Призвание и карьера",
    "Богатство и деньги",
    "Яркость жизни",
    "Самосознание"
  ];

  init() async {
    hokinsKoefs = await repository.getHokins();
    mainData = await getMainReportData();
    configEmotionSphere = await getHokinsSphere("Красота и здоровье");
  }

  notify() {
    notifyListeners();
  }

  List<Question> questionsAndKoeffs = [];
  String moduleName = "";

  //test1
  List<double> ansversM1 = [];
  List<List<List<double>>> hokinsKoefs = [];
  MainData? mainData;
  EmotionData? configEmotionSphere;
  Map<String, double> resultM1 = {};
  Map<String, List<double>> hokinsResultM1 =
      {}; //<гнев, <1, 2, 3, 4,>> список значений в порядке здоровье,отношения ...

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
    localRep.setAnswers("answ1", ansversM1.join("|"));
    step = 1;
    localRep.setTestPassed();
    final answerWeights = [1, 0.75, 0.5, 0.25, 0];
    List<CalculationStep> steps = [];
    if (questionsAndKoeffs.length == ansversM1.length) {
      List<double> result = [0, 0, 0, 0, 0, 0, 0, 0];
      Map<String, List<double>> hokinsResult = Map.fromEntries(
        spheres.map((element) {
          return MapEntry(element, List<double>.filled(16, 0));
        }),
      );
      for (var (i, koeff) in ansversM1.indexed) {
        List<double> intermediateValue = [];
        for (var (j, value) in questionsAndKoeffs[i].indexes.indexed) {
          result[j] += value * koeff;
          intermediateValue.add(value * koeff);
        }
        for (var (ns, sphere) in spheres.indexed) {
          for (var (k, element) in hokinsKoefs[i].indexed) {
            hokinsResult[sphere]?[k] += (element[answerWeights.indexOf(koeff)] *
                    questionsAndKoeffs[i].indexes[ns]) /
                100;
          }
        }
        steps.add(CalculationStep(
          question: questionsAndKoeffs[i].question,
          weights: questionsAndKoeffs[i].indexes,
          coefficient: koeff,
          result: List<double>.from(result),
          hokinsStep: {
            for (var (ns, item) in spheres.indexed)
              item: hokinsKoefs[i]
                  .map((e) =>
                      (e[answerWeights.indexOf(koeff)] *
                          questionsAndKoeffs[i].indexes[ns]) /
                      100)
                  .toList()
          },
          hokinsResult: hokinsResult
              .map((key, value) => MapEntry(key, List<double>.from(value))),
          intermediateValue: List<double>.from(intermediateValue),
        ));
      }
      localRep.saveCalculation(steps);
      firepository.saveTestData(
          jsonEncode(steps.map((step) => step.toJson()).toList()));
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
      hokinsResultM1["Стыд"] = hokinsResult.values.map((e) {
        return e[0];
      }).toList();
      hokinsResultM1["Вина"] = hokinsResult.values.map((e) {
        return e[1];
      }).toList();
      hokinsResultM1["Апатия"] = hokinsResult.values.map((e) {
        return e[2];
      }).toList();
      hokinsResultM1["Горе"] = hokinsResult.values.map((e) {
        return e[3];
      }).toList();
      hokinsResultM1["Страх"] = hokinsResult.values.map((e) {
        return e[4];
      }).toList();
      hokinsResultM1["Жажда"] = hokinsResult.values.map((e) {
        return e[5];
      }).toList();
      hokinsResultM1["Гнев"] = hokinsResult.values.map((e) {
        return e[6];
      }).toList();
      hokinsResultM1["Гордыня"] = hokinsResult.values.map((e) {
        return e[7];
      }).toList();
      hokinsResultM1["Смелость"] = hokinsResult.values.map((e) {
        return e[8];
      }).toList();
      hokinsResultM1["Нейтралитет"] = hokinsResult.values.map((e) {
        return e[9];
      }).toList();
      hokinsResultM1["Готовность"] = hokinsResult.values.map((e) {
        return e[10];
      }).toList();
      hokinsResultM1["Принятие"] = hokinsResult.values.map((e) {
        return e[11];
      }).toList();
      hokinsResultM1["Разум"] = hokinsResult.values.map((e) {
        return e[12];
      }).toList();
      hokinsResultM1["Любовь"] = hokinsResult.values.map((e) {
        return e[13];
      }).toList();
      hokinsResultM1["Гармония"] = hokinsResult.values.map((e) {
        return e[14];
      }).toList();

      notifyListeners();
    }
  }

  List<double> calculateAverages(Map<String, List<double>>? data) {
    if (data == null || data.isEmpty)
      return [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ];

    int maxLength =
        data.values.map((list) => list.length).reduce((a, b) => a > b ? a : b);

    List<double> result = List.generate(maxLength, (index) {
      double sum = 0;
      int count = 0;
      for (var list in data.values) {
        if (index < list.length) {
          sum += list[index];
          count++;
        }
      }
      return count == 0 ? 0.0 : sum / count;
    });

    return result;
  }

  String buildStringByAnswers(String sphere) {
    //mainData
    var result = "";
    var combinationIndex = -1;

    final textsData = mainData?.conclusionCommonInSphere.spheres[sphere];

    textsData?.combinationQuestions.entries.forEach((e) {
      if (e.key == "COMBINATIONQUESTIONS") {
        final answerKoeffs = e.value.map((id){
          return ansversM1[int.parse(id)];
        });
        final combiId = calculateResultIndex(answerKoeffs.toList(), textsData.combinationQuestions["COMBINATION"]??List.empty());
        result += textsData.combinationQuestions["COMBINATION"]?[combiId]??"";
      } else if(e.key == "COMBINATION") {} else {
        result += e.value[(((ansversM1[int.parse(e.key)]*4).toInt()-4).abs())];
      }
    });
    return result;
  }

  int calculateResultIndex(List<double> answers, List<String> resultPatterns) {
    List<double> possibleValues = [1, 0.75, 0.5, 0.25, 0];
    int base = possibleValues.length;

    int calculateIndex(List<double> answers, List<double> possibleValues) {
      int index = 0;
      for (int i = 0; i < answers.length; i++) {
        int position = possibleValues.indexOf(answers[i]);
        index = index * base + position;
      }
      return index;
    }

    return calculateIndex(answers, possibleValues);
  }

  Future<MainData> getMainReportData() async {
    String jsonString =
        await rootBundle.loadString('assets/res/config_texts.json');
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
    configEmotionSphere = null;
    configEmotionSphere = await getHokinsSphere(sphere);
    notifyListeners();
  }

  Future<String> loadJsonString(String sphere) async {
    final p = await localRep.getProfile();
    switch (sphere) {
      case "Красота и здоровье":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_beautyhealth_m.json'
            : 'assets/res/config_hokins_beautyhealth_w.json');
      case "Отношения и любовь":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_love_m.json'
            : 'assets/res/config_hokins_love_w.json');
      case "Призвание и карьера":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_ikigai_m.json'
            : 'assets/res/config_hokins_ikigai_w.json');

      case "Твое окружение":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_relationships_m.json'
            : 'assets/res/config_hokins_relationships_w.json');
      case "Богатство и деньги":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_finance_m.json'
            : 'assets/res/config_hokins_finance_w.json');
      case "Яркость жизни":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_highlife_m.json'
            : 'assets/res/config_hokins_highlife_w.json');
      case "Самосознание":
        return await rootBundle.loadString(p?.male == true
            ? 'assets/res/config_hokins_selfmade_m.json'
            : 'assets/res/config_hokins_selfmade_w.json');
      default:
        throw Exception('Неизвестная сфера: $sphere');
    }
  }

  List<List<double>> getHokinsForQuestion(int qNumber) {
    return hokinsKoefs[qNumber];
  }
}
