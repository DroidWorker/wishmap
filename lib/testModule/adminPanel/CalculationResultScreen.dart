import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../ViewModel.dart';
import '../../navigation/navigation_block.dart';
import '../testingEngine/data/adminModule.dart';
import '../toolWidgets/wavwChart.dart';
import '../toolWidgets/wind_rose.dart';

class CalculationStepsScreen extends StatelessWidget {
  late List<CalculationStep> steps;

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    steps = appViewModel.localRep.getCalculation();
    steps.forEachIndexed((outindex, step) {});
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculation Steps'),
        actions: [
          IconButton(
              onPressed: () {
                BlocProvider.of<NavigationBloc>(context).handleBackPress();
              },
              icon: const Icon(Icons.arrow_back_ios))
        ],
      ),
      body: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          Random random = Random();
          final List<Color> colors = List.generate(
              16,
              (index) => Color.fromARGB(255, random.nextInt(156) + 100,
                  random.nextInt(156) + 100, random.nextInt(156) + 100));
          String text = "";
          final step = steps[index];
          step.weights.forEachIndexed((index, w) {
            text +=
                "($w * ${step.coefficient}) = ${step.intermediateValue[index].toStringAsFixed(3)} -> ${step.result[index].toStringAsFixed(3)}\n";
          });
          return Card(
            child: ListTile(
              title: Text('Step ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.question),
                  Text('Coefficient: ${step.coefficient}'),
                  const Text(
                      "(вес вопроса * коэффициент ответа) = *ответ* -> сумма текущего шага"),
                  Text(text),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: WindRose(values: [
                        step.result[0],
                        step.result[1],
                        step.result[2],
                        step.result[3],
                        step.result[4],
                        step.result[5],
                        step.result[6],
                        step.result[7]
                      ]),
                    ),
                  ),
                  ...step.hokinsStep.entries.mapIndexed((index, entry) {
                    return Text(
                      'Hokins Step ${entry.key}: ${entry.value.join(", ")}',
                      style: TextStyle(color: colors[index]),
                    );
                  }),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: step.hokinsStep.entries.mapIndexed((index, entry) {
                          return LineChartBarData(
                            spots: entry.value
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: colors[index],
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          );
                        }).toList(),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(),
                          bottomTitles: AxisTitles(),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                  ...step.hokinsResult.entries.mapIndexed((index, entry) {
                    return Text(
                        'Hokins Result ${entry.key}: ${entry.value.join(", ")}',
                        style: TextStyle(color: colors[index]));
                  }),
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: step.hokinsResult.entries.mapIndexed((index, entry) {
                          return LineChartBarData(
                            spots: entry.value
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: colors[index],
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          );
                        }).toList(),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(),
                          bottomTitles: AxisTitles(),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
