import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/res/colors.dart';

import '../ViewModel.dart';
import '../common/gradientText.dart';
import '../data/const_common.dart';
import '../navigation/navigation_block.dart';
import '../testModule/testingEngine/ViewModel.dart';

class MyTestingScreen extends StatelessWidget {
  
  List<TestData> data = [];

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    //final map = { for (int i = 0; i < data.length; i++) i: data[i].toMap()};
    //appViewModel.saveMapToFirebase(map);
    appViewModel.getTests();

    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      data = appViewModel.tests;
      final stepsResult = viewModel.localRep.getCalculation();
      final mindLevels = viewModel.configEmotionSphere?.emotions
          .map((k, v) {
            return MapEntry(k, v.score);
          })
          .entries
          .toList();
      double maxHokinsResultEntry =
          stepsResult.lastOrNull?.result.reduce((a, b) => a > b ? a : b) ?? 0;
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
                      const Text("Мое тестирование",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 29)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, top: 8.0),
                              child: Text(
                                "Общий уровень сознания",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.grey)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GradientText(
                                  mindLevels?.firstWhereOrNull((v) {
                                        return v.key ==
                                            hokColors.keys.toList()[stepsResult
                                                    .lastOrNull?.result
                                                    .indexOf(
                                                        maxHokinsResultEntry) ??
                                                0];
                                      })?.value ??
                                      "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                  gradient: const LinearGradient(colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd
                                  ]),
                                ),
                                const SizedBox(
                                  width: 55,
                                  child: Divider(),
                                ),
                                GradientText(
                                  hokColors.keys.toList()[stepsResult
                                          .lastOrNull?.result
                                          .indexOf(maxHokinsResultEntry) ??
                                      0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  gradient: const LinearGradient(colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd
                                  ]),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: constraints.maxWidth - 60,
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: stepsResult
                                      .lastOrNull?.hokinsResult.values.last
                                      .getRange(1, 15)
                                      .mapIndexed((index, entry) {
                                    return LineChartBarData(
                                      spots: [
                                        FlSpot(index.toDouble(), entry),
                                        FlSpot(index.toDouble(), 0)
                                      ].toList(),
                                      isCurved: true,
                                      color: hokColors.values.elementAt(index),
                                      barWidth:
                                          (constraints.maxWidth - 30 - 30) / 16,
                                      isStrokeCapRound: false,
                                      dotData: const FlDotData(show: false),
                                    );
                                  }).toList() ??
                                  [],
                              titlesData: const FlTitlesData(show: false),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...data.map((it){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: testItem(it.title, it.description, it.status, it.hint,
                            (){},
                        () async {
                          List<double> answers = (await viewModel.localRep.getAnswers("answ1")).split("|").map((s) => double.parse(s)).toList();
                          if(answers.isNotEmpty) {
                            viewModel.ansversM1 = answers;
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToReport1ScreenEvent());
                          }
                        }),
                  );
                })
              ],
            ),
          );
        })),
      );
    });
  }
}

Widget testItem(String testTitle, String testDescr, String status, String hint,
    Function() onClick, Function() showTest) {
  return Container(
    padding: const EdgeInsets.all(10),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(testTitle,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: status=="Пройден" ? Colors.green : Colors.red,
              ),
              padding: const EdgeInsets.all(3),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Text(testDescr),
        const SizedBox(height: 15),
        Center(
          child: Text(
            hint,
            style: const TextStyle(color: AppColors.greytextColor),
          ),
        ),
        ColorRoundedButton(status=="Пройден"?"Пройти тест заново":"Пройти", onClick),
        if(status=="Пройден")ColorRoundedButton("Посмотреть тест", showTest, c: Colors.transparent, textColor: Colors.black,)
      ],
    ),
  );
}

class TestData {
  final String title;
  final String description;
  final String status;
  final String hint;

  TestData(this.title, this.description, this.status, this.hint);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'hint': hint
    };
  }

  factory TestData.fromMap(Map<String, dynamic> map) {
    return TestData(
      map['title'],
      map['description'],
      map['status'],
      map['hint'],
    );
  }
}
