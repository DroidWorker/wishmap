import 'dart:convert';

import 'data/models.dart';
import 'package:flutter/services.dart' show rootBundle;

class TestingRepository {
  Future<List<Question>> getQuestions(int page) async {
    String jsonString = await rootBundle.loadString('assets/res/config.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((json) => Question.fromJson(json)).toList();
  }

  Future<List<List<List<double>>>> getHokins() async {
    // Загружаем JSON-строку из файла
    String jsonString = await rootBundle.loadString('assets/res/config_hokins.json');
    // Декодируем JSON-строку в List<dynamic>
    List<dynamic> jsonResponse = json.decode(jsonString);
    // Преобразуем JSON в нужный формат
    return jsonResponse.map((outerList) {
      return (outerList as List<dynamic>).map((innerList) {
        return (innerList as List<dynamic>).map<double>((v) => v.toDouble()).toList();
      }).toList();
    }).toList();
  }


  Future<String> getmoduleName() async {
    return "Модуль 1:  Сферы жизни";
  }
}
