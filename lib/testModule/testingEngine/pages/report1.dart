import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/gradientText.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wishmap/res/colors.dart';
import '../../../common/report_widgets.dart';
import '../../../data/const_common.dart';
import '../../../navigation/navigation_block.dart';
import '../../toolWidgets/circularDiagram.dart';
import '../ViewModel.dart';

class Report1 extends StatefulWidget {
  bool isVideoVisible = true;

  @override
  State<Report1> createState() => Report1State();
}

class Report1State extends State<Report1> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      final testResult = viewModel.resultM1.values.toList();
      //search max hokins result
      final mainData = viewModel.mainData;
      return testResult.isNotEmpty
          ? Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(
                child: showLoader
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : LayoutBuilder(builder: (context, constraints) {
                        var avg = 0.0;
                        for (var v in testResult) {
                          avg += v;
                        }
                        avg = (avg / testResult.length);
                        viewModel.avg = avg.toInt();

                        return SingleChildScrollView(
                            child: Column(children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
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
                                        size: 28,
                                        color: AppColors.gradientStart),
                                    onPressed: () {
                                      BlocProvider.of<NavigationBloc>(context)
                                          .handleBackPress();
                                    }),
                                const Text("Сферы жизни",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                const SizedBox(width: 29)
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              "Цель данного отчета — предоставить комплексный обзор текущего состояния этих сфер, выявить ключевые проблемы и предложить рекомендации для их оптимизации, что позволит каждому человеку стремиться к более гармоничной и полноценной жизни",
                              style: TextStyle(color: Color(0xFFB2B2BF)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Диаграмма сфер",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 30),
                                    Center(
                                        child: RadialChart(filledSections: [
                                      (testResult[0] / 10).toInt(),
                                      (testResult[1] / 10).toInt(),
                                      (testResult[2] / 10).toInt(),
                                      (testResult[3] / 10).toInt(),
                                      (testResult[4] / 10).toInt(),
                                      (testResult[5] / 10).toInt(),
                                      (testResult[6] / 10).toInt(),
                                      (testResult[7] / 10).toInt()
                                    ])),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.grey)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GradientText(
                                              "${avg.toInt()}%",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30),
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.gradientStart,
                                                    AppColors.gradientEnd
                                                  ]),
                                            ),
                                            const GradientText(
                                              "Средний уровень",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              gradient: LinearGradient(colors: [
                                                AppColors.gradientStart,
                                                AppColors.gradientEnd
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        mainData?.conclusionByPercent
                                                .conclusionByPercent.values
                                                .toList()[(((avg.toInt() == 100)
                                                    ? 99
                                                    : avg.toInt()) ~/
                                                10)] ??
                                            "",
                                        style: const TextStyle(
                                            color: AppColors.greytextColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Center(
                                      child: Text(
                                        "Однако, ты тут чтобы все изменить!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 21),
                                    ...colors.keys.mapIndexed((i, e) {
                                      final value = i < 3
                                          ? testResult[i]
                                          : i == 3
                                              ? (testResult[i] +
                                                      testResult[i + 1]) /
                                                  2
                                              : testResult[i + 1];
                                      return SphereButtonItem(
                                        colors[e] ?? Colors.blue,
                                        value.toInt(),
                                        e,
                                        () async {
                                          setState(() {
                                            showLoader = true;
                                          });
                                          viewModel.configEmotionSphere =
                                              await viewModel
                                                  .getHokinsSphere(e);
                                          setState(() {
                                            showLoader = false;
                                          });
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(
                                            NavigateToReportInfoScreenScreenEvent(
                                                e, i),
                                          );
                                        },
                                      );
                                    }),
                                  ])),
                          const SizedBox(height: 25),
                          /* Container(
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: constraints.maxWidth,
                                  child: const Text(
                                    "Общий уровень сознания",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: AppColors.grey)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GradientText(
                                          mindLevels?.firstWhereOrNull((v) {
                                                return v.key ==
                                                    maxHokinsResultEntry.key;
                                              })?.value ??
                                              "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30),
                                          gradient: const LinearGradient(
                                              colors: [
                                                AppColors.gradientStart,
                                                AppColors.gradientEnd
                                              ]),
                                        ),
                                        GradientText(
                                          maxHokinsResultEntry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          gradient: const LinearGradient(
                                              colors: [
                                                AppColors.gradientStart,
                                                AppColors.gradientEnd
                                              ]),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
                                SizedBox(
                                  width: constraints.maxWidth - 60,
                                  height: 200,
                                  child: LineChart(
                                    LineChartData(
                                      lineBarsData: hokinsResult.entries
                                          .mapIndexed((index, entry) {
                                        return LineChartBarData(
                                          spots: [
                                            FlSpot(
                                                index.toDouble(), entry.value),
                                            FlSpot(index.toDouble(), 0)
                                          ].toList(),
                                          isCurved: true,
                                          color: hokColors[entry.key],
                                          barWidth:
                                              (constraints.maxWidth - 30 - 30) /
                                                  16,
                                          isStrokeCapRound: false,
                                          dotData: const FlDotData(show: false),
                                        );
                                      }).toList(),
                                      titlesData:
                                          const FlTitlesData(show: false),
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  width: constraints.maxWidth,
                                  child: const Text(
                                    "Уровень сознания",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: constraints.maxWidth,
                                  child: const Text(
                                      "У тебя сейчас такой период, когда т"),
                                ),
                                ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.greytextColor,
                                              AppColors.grey
                                            ]).createShader(
                                          Rect.fromLTWH(0, 0, bounds.width,
                                              bounds.height),
                                        ),
                                    child: Container(
                                      width: constraints.maxWidth,
                                      child: Text(
                                          "ы неустанно ищешь идеальные способы, чтобы достичь желаемой внешности и крепкого здоровья. Ты представляешь себя..."),
                                    )),
                                const SizedBox(height: 25),
                                /*RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                      text:
                                          "Блок доступен для пользователей,\n достигших",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.greytextColor),
                                      children: [
                                        TextSpan(
                                            text: " средний уровень",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black))
                                      ]),
                                ),
                                const SizedBox(height: 15),
                                ColorRoundedButton("Изучить", () {})*/
                              ],
                            ),
                          )*/
                        ]));
                      }),
              ))
          : inCalculating();
    });
  }

  Widget inCalculating() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: appbarColor,
          scrolledUnderElevation: 0,
          toolbarHeight: 90,
          title: Center(
            child: Image.asset(
              'assets/res/images/logo.png',
              height: 90,
            ),
          )),
      body: const Center(
        child: Text("Вычисляем результаты"),
      ),
    );
  }
}
