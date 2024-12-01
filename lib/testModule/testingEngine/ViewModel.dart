import 'package:flutter/cupertino.dart';

import 'data/models.dart';
import 'testingRepository.dart';

class TestViewModel extends ChangeNotifier{
  final repository = TestingRepository();
  bool isInLoading = false;
  init() {
    hokinsKoefs = repository.getHokins();
  }
  List<Question> questionsAndKoeffs = [];
  String moduleName = "";
  //test1
  List<double> ansversM1 = [];
  List<List<List<int>>> hokinsKoefs = [];
  Map<String, double> resultM1 = {};
  Map<String, double> hokinsResultM1 = {};
  Future getmoduleName()async {
    moduleName = await repository.getmoduleName();
  }
  Future getQuestions()async {
    questionsAndKoeffs = await repository.getQuestions(1);
    notifyListeners();
  }
  Future getHokinsKoefs()async {
    hokinsKoefs = await repository.getHokins();
    notifyListeners();
  }
  Future calculateResult()async {
    final answerWeights = [1, 0.75, 0.5, 0.25, 0];
    final hoking = repository.getHokins();
    if(questionsAndKoeffs.length==ansversM1.length){
      List<double> result = [0, 0, 0, 0, 0, 0, 0, 0];
      List<double> hokinsResult = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      for (var (i, koeff) in ansversM1.indexed) {
        for (var (j, value) in questionsAndKoeffs[i].indexes.indexed) {
          result[j] += value*koeff;
        }
        for (var (k,element) in hoking[i][answerWeights.indexOf(koeff)].indexed) {
          hokinsResult[k] += element;
        }
      }
      resultM1["Здоровье"] = result[0];
      resultM1["Отношения"] = result[1];
      resultM1["Окружение"] = result[2];
      resultM1["Призвание"] = result[3];
      resultM1["Богатство"] = result[4];
      resultM1["Саморазвитие"] = result[5];
      resultM1["Яркость жизни"] = result[6];
      resultM1["Духовность"] = result[7];

      for (var (i, element) in hokinsResult.indexed) {
        hokinsResult[i] = element/100;
      }
      hokinsResultM1["Стыд/Позор"] = hokinsResult[0];
      hokinsResultM1["Вина"] = hokinsResult[1];
      hokinsResultM1["Апатия"] = hokinsResult[2];
      hokinsResultM1["Горе"] = hokinsResult[3];
      hokinsResultM1["Страх"] = hokinsResult[4];
      hokinsResultM1["Вожделение"] = hokinsResult[5];
      hokinsResultM1["Гнев"] = hokinsResult[6];
      hokinsResultM1["Гордость"] = hokinsResult[7];
      hokinsResultM1["Смелость"] = hokinsResult[8];
      hokinsResultM1["Нейтралитет"] = hokinsResult[9];
      hokinsResultM1["Готовность"] = hokinsResult[10];
      hokinsResultM1["Принятие"] = hokinsResult[11];
      hokinsResultM1["Разумность"] = hokinsResult[12];
      hokinsResultM1["Любовь"] = hokinsResult[13];
      hokinsResultM1["Радость"] = hokinsResult[14];
      hokinsResultM1["Покой"] = hokinsResult[15];

      notifyListeners();
    }
  }

  List<List<int>> getHokinsForQuestion(int qNumber) {
    return hokinsKoefs[qNumber];
  }
}