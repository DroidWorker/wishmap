import 'package:flutter/material.dart';
import 'dart:math';

class WindRose extends StatelessWidget {
  final List<double> values;

  const WindRose({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(200, 200),
      painter: WindRosePainter(values: values),
    );
  }
}

class WindRosePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels = ["Богатство", "Саморазвитие", "Яркость жизни", "Духовность", "Здоровье", "Отношения", "Окружение", "Призвание"];

  WindRosePainter({required this.values}){
    values.add(values[0]);
    values.add(values[1]);
    values.removeAt(0);
    values.removeAt(0);
  }

  final Paint borderPaint = Paint()
    ..color = const Color.fromARGB(255, 158, 1, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint fillPaint = Paint()
    ..color = const Color.fromARGB(255, 255, 0, 107).withOpacity(0.3) // Задайте цвет заливки с некоторой непрозрачностью
    ..style = PaintingStyle.fill;

  final Paint pointPaint = Paint()
    ..color = const Color.fromARGB(255, 158, 1, 255)
    ..style = PaintingStyle.fill;

  final double maxValue = 100;//values.reduce((value, element) => value > element ? value : element);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path fillPath = Path();

    for (int i = 0; i < 8; i++) {
      final double angle = i * (pi / 4);
       double normalizedValue = values[i] / maxValue;
      final double pointX = centerX + normalizedValue * radius * cos(angle);
      final double pointY = centerY + normalizedValue * radius * sin(angle);

      if (i == 0) {
        fillPath.moveTo(pointX, pointY);
      }

      canvas.drawCircle(Offset(pointX, pointY), 2.0, pointPaint);

      if (i < 7) {
        final double nextAngle = (i + 1) * (pi / 4);
        final double nextNormalizedValue = values[i + 1] / maxValue;
        final double nextPointX = centerX + nextNormalizedValue * radius * cos(nextAngle);
        final double nextPointY = centerY + nextNormalizedValue * radius * sin(nextAngle);
        var xMov = 0.0;
        var yMov = 0.0;
        switch(i){
          case 0:
            xMov = pointX;
            yMov = (pointY+nextPointY)/2;
            break;
          case 1:
            xMov = (pointX+nextPointX)/2;
            yMov = nextPointY;
            break;
          case 2:
            xMov = (nextPointX+pointX)/2;
            yMov = pointY;
            break;
          case 3:
            xMov = nextPointX;
            yMov = (pointY+nextPointY)/2;
            break;
          case 4:
            xMov = pointX;
            yMov = (pointY+nextPointY)/2;
            break;
          case 5:
            xMov = (pointX+nextPointX)/2;
            yMov = nextPointY;
            break;
          case 6:
            xMov = pointX+(nextPointX-pointX)/2;
            yMov = pointY;
            break;
        }

        fillPath.quadraticBezierTo(
          //pointX + (nextPointX - pointX) / 2, pointY,
          xMov, yMov,
          nextPointX, nextPointY,
        );

        fillPath.lineTo(nextPointX, nextPointY);
      }
    }

    // Соединяем первую и последнюю точки линией
    final double firstAngle = 0;
    final double firstNormalizedValue = values[0] / maxValue;
    final double firstPointX = centerX + firstNormalizedValue * radius * cos(firstAngle);
    final double firstPointY = centerY + firstNormalizedValue * radius * sin(firstAngle);

    fillPath.quadraticBezierTo(
      //pointX + (nextPointX - pointX) / 2, pointY,
      firstPointX, firstPointY*0.75,
      firstPointX, firstPointY,
    );
    fillPath.lineTo(firstPointX, firstPointY);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(fillPath, borderPaint);

    // Рисуем розу ветров
    int i = 0;
    for (double angle = 0; angle < 2 * pi; angle += pi / 4) {
      final double x = centerX + (radius + 10) * cos(angle);
      final double y = centerY + (radius + 10) * sin(angle);
      final Offset start = Offset(centerX, centerY);
      final Offset end = Offset(x, y);
      canvas.drawLine(start, end, paint);

      // Рисуем текст
      final TextSpan span = TextSpan(
        text: labels[i], // Используем названия из списка labels
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      // Отодвигаем текст относительно центра на половину ширины текста
      final double textX = centerX + (radius + 30) * cos(angle+pi/2); // Добавляем 30 для дополнительного расстояния от вектора
      final double textY = centerY + (radius + 30) * sin(angle+pi/2); // Добавляем 30 для дополнительного расстояния от вектора

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(angle + pi); // Поворачиваем текст на 180 градусов
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      i++;
    }

    // Рисуем окружности, представляющие уровни розы ветров
    final Paint circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * (i / 5),
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}