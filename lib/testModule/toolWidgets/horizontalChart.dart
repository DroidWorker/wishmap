import 'package:wishmap/res/colors.dart';
import 'package:flutter/material.dart';

class BarData {
  final String label;
  final double value;
  final Color color;
  final int maxValue;

  BarData({required this.label, required this.value, required this.maxValue, required this.color});
}


class HorizontalBarChart extends StatelessWidget {
  final List<BarData> barDataList;

  HorizontalBarChart({super.key, required this.barDataList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: barDataList.map((barData) {
        return HorizontalBarWidget(barData: barData);
      }).toList(),
    );
  }
}

class HorizontalBarWidget extends StatelessWidget {
  final BarData barData;
  final double progressBarHeight = 20.0; // Новая высота прогресс-бара

  HorizontalBarWidget({required this.barData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(width: 100,
            child: Text(
            barData.label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),),
          const SizedBox(width: 8),
          Expanded(child: LayoutBuilder(builder: (context, constraints){
            final dividersCount = constraints.maxWidth~/20;
            return SizedBox(
                height: progressBarHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: LinearProgressIndicator(
                        value: barData.value / barData.maxValue,
                        backgroundColor: buttonGrey,
                        valueColor: AlwaysStoppedAnimation<Color>(barData.color),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dividersCount-1, (index) {
                        return Container(
                          width: constraints.maxWidth / dividersCount - 1, // Исправлено
                          height: progressBarHeight,
                          margin: const EdgeInsets.only(right: 1), // Исправлено
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: bgMainColor,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                )
            );
          })),
          const SizedBox(width: 8),
          Text(
            barData.value.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
