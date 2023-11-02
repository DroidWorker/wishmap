import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';

class MoonWidget extends StatelessWidget {
  final double fillPercentage; // Процентное заполнение Луны
  double moonSize=100;

  MoonWidget({super.key, required this.fillPercentage, required this.moonSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(moonSize, moonSize), // Устанавливаем размер для Луны (можете настроить по своему усмотрению)
      painter: MoonPainter(fillPercentage),
    );
  }
}

class MoonPainter extends CustomPainter {
  final double fillPercentage;

  MoonPainter(this.fillPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final moonRadius = size.width/2;
    final moonCenter = Offset(size.width / 2, size.height / 2);

    final moonPaint = Paint()..color = AppColors.moonColor; // Цвет Луны

    // Рисуем заднюю окружность (окружность Луны)
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Рассчитываем смещение передней окружности относительно задней
    final offset = Offset((2*moonRadius)-fillPercentage*2*moonRadius, 0.0);

    // Рисуем переднюю окружность (сжатую часть Луны) с смещением
    final frontCirclePaint = Paint()..color = AppColors.backgroundColor;
    canvas.drawCircle(moonCenter + offset, moonRadius, frontCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
