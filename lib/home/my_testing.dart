import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/res/colors.dart';

import '../common/gradientText.dart';
import '../data/const_common.dart';
import '../navigation/navigation_block.dart';
import '../testModule/testingEngine/ViewModel.dart';

class MyTestingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TestViewModel>(builder: (context, viewModel, child)
    {
      final stepsResult = viewModel.localRep.getCalculation();
      final mindLevels = viewModel.configEmotionSphere?.emotions
          .map((k, v) {
        return MapEntry(k, v.score);
      })
          .entries
          .toList();
      double maxHokinsResultEntry = stepsResult.lastOrNull?.result.reduce((a, b) => a > b ? a : b)??0;
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: const Icon(Icons.keyboard_arrow_left,
                          size: 28, color: AppColors.gradientStart),
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .handleBackPress();
                      }),
                  const Text("Мое тестирование",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 29)
                ],
              ),
              Container(
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
                                return v.key == hokColors.keys.toList()[stepsResult.lastOrNull?.result.indexOf(maxHokinsResultEntry)??0];
                              })?.value ??
                                  "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
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
                              hokColors.keys.toList()[stepsResult.lastOrNull?.result.indexOf(maxHokinsResultEntry)??0],
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
                          lineBarsData:
                          stepsResult.lastOrNull?.result.mapIndexed((index, entry) {
                            return LineChartBarData(
                              spots: [
                                FlSpot(index.toDouble(), entry),
                                FlSpot(index.toDouble(), 0)
                              ].toList(),
                              isCurved: true,
                              color: hokColors.values.elementAt(index),
                              barWidth: (constraints.maxWidth - 30 - 30) / 16,
                              isStrokeCapRound: false,
                              dotData: const FlDotData(show: false),
                            );
                          }).toList()??[],
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        })),
      );
    });
    }
}

Widget testItem(String testTitle, String testDescr, String status, String hint, Function() onClick) {
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
            const Text("Сферы жизни",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              child: const Text(
                "Пройден",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Text(
            "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни."),
        const SizedBox(height: 15),
        Center(child: Text("Доступен к 15.11.2024", style: TextStyle(color: AppColors.greytextColor),),),
        ColorRoundedButton("Изучить", onClick)
      ],
    ),
  );
}
