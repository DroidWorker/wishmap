import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';
import '../navigation/navigation_block.dart';
import '../testModule/testingEngine/ViewModel.dart';

class MyKnwlgsScreen extends StatelessWidget {
  List<LevelData> knowleges = [];

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    appViewModel.getKnowledges();
    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      knowleges = appViewModel.knowlegesData;
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // the '2023' part
                          ),
                          icon: const Icon(Icons.keyboard_arrow_left,
                              size: 28, color: AppColors.gradientStart),
                          onPressed: () {
                            BlocProvider.of<NavigationBloc>(context)
                                .handleBackPress();
                          }),
                      const Text("Мои знания",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 29)
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: knowleges.map((it) {
                        return LevelItem(it.title, it.items);
                      }).toList()
                      /*LevelItem("Базовый уровень", [
                          LevelItemData(
                              "Вводный курс",
                              "Пройден",
                              "Доступен к 15.11.2024",
                              0,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Наполнение карты",
                              "Не пройден ",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Актуализация",
                              "Не пройден",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни.")
                        ]),
                        LevelItem("Средний уровень", [
                          LevelItemData(
                              "Вводный курс",
                              "Пройден",
                              "Доступен к 15.11.2024",
                              0,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Наполнение карты",
                              "Не пройден ",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Актуализация",
                              "Не пройден",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни.")
                        ]),
                        LevelItem("Продвинутый уровень", [
                          LevelItemData(
                              "Вводный курс",
                              "Пройден",
                              "Доступен к 15.11.2024",
                              0,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Наполнение карты",
                              "Не пройден ",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
                          LevelItemData(
                              "Актуализация",
                              "Не пройден",
                              "Доступен к 15.11.2024",
                              1,
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни.")
                        ])*/
                      ,
                    ))
              ],
            ),
          );
        })),
      );
    });
  }
}

class LevelItem extends StatefulWidget {
  final String title;
  final List<LevelItemData> data;

  LevelItem(this.title, this.data, {super.key});

  @override
  LevelItemState createState() => LevelItemState();
}

class LevelItemState extends State<LevelItem> {
  bool expanded = false;
  final levelTexts = {
    "Базовый уровень": Colors.green,
    "Продвинутый": Colors.red
  };

  @override
  Widget build(BuildContext context) {
    final levels = widget.data.map((e) {
      return e.level;
    }).toSet();
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.darkGrey,
                )
              ],
            ),
          ),
          if (expanded) const Divider(),
          if (expanded)
            Column(
              children: [
                ...levels.map((e) {
                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: levelTexts.values.toList()[e],
                          ),
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              levelTexts.keys.toList()[e],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          // Use Expanded to keep the column in place
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: widget.data
                                  .where((i) => i.level == e)
                                  .map<Widget>((e) {
                                return Subitem(e, () {});
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ],
            ),
        ],
      ),
    );
  }
}

Widget Subitem(LevelItemData data, Function() onClick) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Wrap text in Expanded to prevent overflow
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              padding: const EdgeInsets.all(3),
              child: Text(
                data.title,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Text(data.description),
        const SizedBox(height: 15),
        Center(
          child: Text(
            data.hint,
            style: const TextStyle(color: AppColors.greytextColor),
          ),
        ),
        ColorRoundedButton("Изучить", onClick),
        const SizedBox(height: 6)
      ],
    ),
  );
}

class LevelData {
  final String title;
  final List<LevelItemData> items;

  LevelData(this.title, this.items);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'items': items.map((it) {
        return it.toMap();
      }).toList(),
    };
  }

  factory LevelData.fromMap(Map<String, dynamic> map) {
    var items = (map['items'] as List)
        .map((item) =>
            LevelItemData.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
    return LevelData(
      map['title'],
      items,
    );
  }
}

class LevelItemData {
  final int level;
  final String title;
  final String status;
  final String description;
  final String hint;

  LevelItemData(
      this.title, this.status, this.hint, this.level, this.description);

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'title': title,
      'status': status,
      'description': description,
      'hint': hint
    };
  }

  factory LevelItemData.fromMap(Map<String, dynamic> map) {
    return LevelItemData(
      map['title'],
      map['status'],
      map['hint'],
      map['level'],
      map['description']
    );
  }
}
