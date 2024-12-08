import 'dart:convert';

import 'data/models.dart';
import 'package:flutter/services.dart' show rootBundle;

class TestingRepository {
  Future<List<Question>> getQuestions(int page) async {
    String jsonString = await rootBundle.loadString('assets/res/config.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((json) => Question.fromJson(json)).toList();
  }

  List<List<List<int>>> getHokins() {
    List<List<int>> hokins1 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 15, 20, 15, 12, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins2 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 9, 12, 15, 20, 12, 6, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 15, 20, 15, 12, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins3 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins4 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins5 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins6 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins7 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins8 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins9 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins10 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins11 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins12 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins13 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins14 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins15 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];
    List<List<int>> hokins16 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins17 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins18 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins19 = [
      [1, 1, 1, 1, 3, 7, 11, 12, 15, 20, 15, 6, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [15, 20, 15, 12, 12, 8, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins20 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1],
    ];
    List<List<int>> hokins21 = [
      [1, 1, 1, 1, 3, 7, 11, 15, 20, 15, 11, 7, 3, 2, 1, 1],
      [1, 2, 3, 7, 10, 15, 20, 12, 10, 7, 5, 3, 2, 1, 1, 1],
      [5, 6, 7, 10, 15, 20, 15, 7, 5, 3, 2, 1, 1, 1, 1, 1],
      [7, 10, 12, 15, 20, 15, 9, 3, 2, 1, 1, 1, 1, 1, 1, 1],
      [10, 12, 15, 20, 15, 10, 6, 3, 2, 1, 1, 1, 1, 1, 1, 1]
    ];

    return [
      hokins1,
      hokins2,
      hokins3,
      hokins4,
      hokins5,
      hokins6,
      hokins7,
      hokins8,
      hokins9,
      hokins10,
      hokins11,
      hokins12,
      hokins13,
      hokins14,
      hokins15,
      hokins16,
      hokins17,
      hokins18,
      hokins19,
      hokins20,
      hokins21,
      hokins13,
      hokins14,
      hokins15,
      hokins16,
      hokins17,
      hokins18,
      hokins19,
      hokins20,
      hokins21,
      hokins13,
      hokins14,
      hokins15,
      hokins16,
      hokins17,
      hokins18,
      hokins19,
      hokins20,
      hokins21
    ];
  }

  Future<String> getmoduleName() async {
    return "Модуль 1:  Сферы жизни";
  }
}
