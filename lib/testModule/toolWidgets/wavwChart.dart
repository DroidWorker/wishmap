import 'dart:math';
import 'package:flutter/material.dart';

import '../tools/tools.dart';

class CustomLineChart extends StatelessWidget {
  final Map<String, double> data;
  final List<double> expectations;

  CustomLineChart({required this.data, required this.expectations});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints){
      return Container(
        padding: EdgeInsets.all(16.0),
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxWidth*0.35), // Задайте размер графика
          painter: LineChartPainter(data, expectations, calculateExpectation(data.values.toList(), expectations)),
        ),
      );
    });
  }
}

class LineChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<double> expectations;
  final double expectationValue;
  int expectationLocation = 0;

  LineChartPainter(this.data, this.expectations, this.expectationValue);

  @override
  void paint(Canvas canvas, Size size) {
    double minDifference = double.infinity;

    for (int i = 0; i < expectations.length; i++) {
      double difference = (expectations[i]*100 - expectationValue*10.0).abs();
      if (difference < minDifference) {
        minDifference = difference;
        expectationLocation = i;
      }
    }

    const double paddingTop = 20.0;
    const double paddingBottom = 20.0;
    const double paddingLeft = 20.0;
    const double paddingRight = 20.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final double maxValue = expectations.reduce(max) + 1;
    final double xInterval = chartWidth / (data.length - 1);
    final double yInterval = chartHeight / maxValue;

    // Рисуем горизонтальные линии сетки
    for (double i = 0; i <= maxValue; i += maxValue / 4) {
      final double y = size.height - paddingBottom - i * yInterval;
      canvas.drawLine(
          Offset(paddingLeft, y), Offset(size.width - paddingRight, y), Paint()
        ..color = Colors.grey);
      // Подписываем значения сетки
      TextSpan span = TextSpan(
        text: i.toStringAsFixed(1),
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      TextPainter tp = TextPainter(
          text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(paddingLeft - tp.width - 5, y - tp.height / 2));
    }

    // Рисуем сглаженный график
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = paddingLeft + i * xInterval;
      final double y = size.height - paddingBottom - data.values.elementAt(i) * yInterval;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final double prevX = paddingLeft + (i - 1) * xInterval;
        final double prevY = size.height - paddingBottom - data.values.elementAt(i - 1) * yInterval;

        // Рассчитываем коэффициент силы изгиба
        final double curveFactor = 0.2; // Экспериментируйте с этим значением

        // Рассчитываем контрольные точки на основе коэффициента силы изгиба
        final double controlX1 = prevX + xInterval / 2;
        final double controlY1 = prevY + curveFactor * (y - prevY);
        final double controlX2 = x - xInterval / 2;
        final double controlY2 = y - curveFactor * (y - prevY);
        final double endX = x;
        final double endY = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
      }
    }


    canvas.drawPath(path, linePaint);

    // Рисуем второй график (expectations)
    Path pathExpectations = Path();

    for (int i = 0; i < expectations.length; i++) {
      final double x = paddingLeft + i * xInterval;
      final double y = size.height - paddingBottom - expectations[i] * yInterval;

      if (i == 0) {
        pathExpectations.moveTo(x, y);
      } else {
        final double prevX = paddingLeft + (i - 1) * xInterval;
        final double prevY = size.height - paddingBottom - expectations[i - 1] * yInterval;

        // Рассчитываем коэффициент силы изгиба
        final double curveFactor = 0.2; // Экспериментируйте с этим значением

        // Рассчитываем контрольные точки на основе коэффициента силы изгиба
        final double controlX1 = prevX + xInterval / 2;
        final double controlY1 = prevY + curveFactor * (y - prevY);
        final double controlX2 = x - xInterval / 2;
        final double controlY2 = y - curveFactor * (y - prevY);

        pathExpectations.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

// Рисуем второй график
    canvas.drawPath(pathExpectations, linePaint..color = Colors.red..strokeJoin = StrokeJoin.round);

    // Подписываем значения оси X
    for (int i = 0; i < data.length; i++) {
      final double x = paddingLeft + i * xInterval;
      TextSpan span = TextSpan(
        text: data.keys.elementAt(i),
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      TextPainter tp = TextPainter(
          text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(
          canvas, Offset(x - tp.width / 2, size.height - paddingBottom + 5));
    }

    // Рисуем вертикальную черту математического ожидания
    Paint linePaintExpectation = Paint()
      ..color = Colors.black54 // Цвет черты математического ожидания
      ..strokeWidth = 1.0;

    double expectationX = paddingLeft + expectationLocation * xInterval;
    double expectationY = size.height - paddingBottom - chartHeight;
    canvas.drawLine(
      Offset(expectationX, size.height - paddingBottom),
      Offset(expectationX, expectationY),
      linePaintExpectation,
    );

// Добавляем текст математического ожидания
    TextSpan expectationTextSpan = TextSpan(
      text: 'среднее значение: ${(expectationValue.toInt() * 10).toString()}',
      style: const TextStyle(color: Colors.black, fontSize: 8),
    );
    TextPainter expectationTextPainter = TextPainter(
        text: expectationTextSpan, textDirection: TextDirection.ltr);
    expectationTextPainter.layout();
    expectationTextPainter.paint(canvas, Offset(
        expectationX - expectationTextPainter.width / 2,
        expectationY - expectationTextPainter.height - 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}