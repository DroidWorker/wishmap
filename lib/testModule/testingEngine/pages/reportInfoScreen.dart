import 'dart:ffi';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../common/gradientText.dart';
import '../../../common/report_widgets.dart';
import '../../../data/const_common.dart';
import '../../../navigation/navigation_block.dart';
import '../../../res/colors.dart';
import '../ViewModel.dart';

class ReportInfoScreen extends StatelessWidget {
  bool isVideoVisible = true;
  String sphere = "";

  ReportInfoScreen(this.sphere, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestViewModel>(builder: (context, viewModel, child) {
      final commonText = viewModel.buildStringByAnswers(sphere);
      final testResult = viewModel.resultM1.values.toList();
      final hokinsResult = viewModel.hokinsResultM1;
      MapEntry<String, double> maxHokinsResultEntry =
          hokinsResult.entries.reduce((a, b) => a.value > b.value ? a : b);
      final configEmotion =
          viewModel.configEmotionSphere?.emotions[maxHokinsResultEntry.key];
      final mindLevels = viewModel.configEmotionSphere?.emotions
          .map((k, v) {
            return MapEntry(k, v.score);
          })
          .entries
          .toList();

      return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
                child: Column(children: [
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
                  Text(sphere,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 29)
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text("Описание", style: TextStyle(fontSize: 18),),
                    const SizedBox(height: 20),
                    Text(commonText),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(children: [
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
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  gradient: const LinearGradient(colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd
                                  ]),
                                ),
                                const SizedBox(width: 55,child: Divider(),),
                                GradientText(
                                  maxHokinsResultEntry.key,
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
                        /*SizedBox(
                          width: constraints.maxWidth - 60,
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: hokinsResult.entries
                                  .mapIndexed((index, entry) {
                                return LineChartBarData(
                                  spots: [
                                    FlSpot(index.toDouble(), entry.value),
                                    FlSpot(index.toDouble(), 0)
                                  ].toList(),
                                  isCurved: true,
                                  color: hokColors[entry.key],
                                  barWidth:
                                      (constraints.maxWidth - 30 - 30) / 16,
                                  isStrokeCapRound: false,
                                  dotData: const FlDotData(show: false),
                                );
                              }).toList(),
                              titlesData: const FlTitlesData(show: false),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),*/
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.grey)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Архетип",
                                              style: TextStyle(
                                                  color: AppColors.greytextColor),
                                            ),
                                            GradientText(
                                              configEmotion
                                                  ?.text.entries.firstOrNull?.key ??
                                                  "",
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
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.grey)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Восприятие жизни",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.greytextColor),
                                            ),
                                            Text(
                                              configEmotion?.perception ?? "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, color: Colors.green),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(configEmotion?.text.entries.firstOrNull?.value ?? ""),
                              const SizedBox(height: 10),
                              if (configEmotion != null)
                                for (final item in configEmotion.text.entries.skip(1))
                                  ExpandedItem(item.key, item.value),
                            ],
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                Border.all(color: AppColors.grey)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GradientText(
                                  "${viewModel.avg.toInt()}%",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                  gradient: const LinearGradient(colors: [
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
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              viewModel.mainData?.conclusionByPercent
                                  .conclusionByPercent.values
                                  .toList()[viewModel.avg.toInt() ~/ 10] ??
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
                                ? (testResult[i] + testResult[i + 1]) /
                                2
                                : testResult[i + 1];
                            return SphereButtonItem(
                                colors[e] ?? Colors.blue, value.toInt(), e,
                                    () {
                                  viewModel.buildConfigAsync(e);
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                  BlocProvider.of<NavigationBloc>(context).add(
                                      NavigateToReportInfoScreenScreenEvent(e));
                                });
                          })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]));
          })));
    });
  }
}

class ExpandedItem extends StatefulWidget{
  final String title;
  final String text;

  ExpandedItem(this.title, this.text, {super.key});

  @override
  ExpandedItemState createState() => ExpandedItemState();
}

class ExpandedItemState extends State<ExpandedItem>{
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold),)),
                  Icon(
                    expanded?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,
                    color: AppColors.darkGrey,
                  )
                ],
              ),
              if (expanded) const Divider(),
              if (expanded) Text(widget.text)
            ],
          ),
        ),
      ),
    );
  }
}
