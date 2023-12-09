import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';
import 'dart:math';

/*class MoonWidget extends StatelessWidget {
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
**/
class MoonWidget extends StatelessWidget {
  ///DateTime to show.
  ///Even hour, minutes, and seconds are calculated for MoonWidget
  final DateTime date;

  ///Decide the container size for the MoonWidget
  final double size;

  ///Resolution will be the moon radius.
  ///Large resolution needs more math operation makes widget heavy.
  ///Enter a small number if it is sufficient to mark it small,
  ///such as an icon or marker.
  final double resolution;

  ///Color of light side of moon
  final Color moonColor;

  ///Color of dark side of moon
  final Color earthshineColor;

  const MoonWidget({
    Key? key,
    required this.date,
    this.size = 36,
    this.resolution = 96,
    this.moonColor = AppColors.moonColor,
    this.earthshineColor = AppColors.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform.scale(
        scale: size / (resolution * 2),
        child: CustomPaint(
          size: Size(size,size),
          painter: MoonPainter(moonWidget: this),
        ),
      ),
    );
  }
}

class MoonPainter extends CustomPainter {
  MoonWidget moonWidget;
  final Paint paintDark = Paint();
  final Paint paintLight = Paint();
  final MoonPhase moon = MoonPhase();

  MoonPainter({required this.moonWidget});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = moonWidget.resolution;

    int width = radius.toInt() * 2;
    int height = radius.toInt() * 2;
    double phaseAngle = moon.getPhaseAngle(moonWidget.date);

    double xcenter = 0;
    double ycenter = 0;

    try {
      paintLight.color = moonWidget.moonColor;
      //달의 색깔로 전체 원을 그린다
      canvas.drawCircle(const Offset(0, 1), radius, paintLight);
    } catch (e) {
      radius = min(width, height) * 0.4;
      paintLight.color = moonWidget.moonColor;
      Rect oval = Rect.fromLTRB(xcenter - radius, ycenter - radius,
          xcenter + radius, ycenter + radius);
      canvas.drawOval(oval, paintLight);
    }

    ///위상각은 태양 - 달 - 지구의 각도다.
    ///따라서 0 = full phase, 180 = new
    ///우리가 필요한 것은 일출 터미네이터의 위치 각도(태양 - 지구 - 달)다.
    ///위상각과 반대 방향이기 때문에 변환해야한다.
    double positionAngle = pi - phaseAngle;
    if (positionAngle < 0.0) {
      positionAngle += 2.0 * pi;
    }

    //이제 어두운 면을 그려야 한다.
    paintDark.color = moonWidget.earthshineColor;

    double cosTerm = cos(positionAngle);

    double rsquared = radius * radius;
    double whichQuarter = ((positionAngle * 2.0 / pi) + 4) % 4;

    for (int j = 0; j < radius; ++j) {
      double rrf = sqrt(rsquared - j * j);
      double rr = rrf;
      double xx = rrf * cosTerm;
      double x1 = xcenter - (whichQuarter < 2 ? rr : xx);
      double w = rr + xx;
      canvas.drawRect(
          Rect.fromLTRB(x1, ycenter - j, w + x1, ycenter - j + 2), paintDark);
      canvas.drawRect(
          Rect.fromLTRB(x1, ycenter + j, w + x1, ycenter + j + 2), paintDark);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MoonPhase {
  final deg2rad = pi / 180;

  // convert degrees to a valid angle:
  double angle(double deg) {
    while (deg >= 360.0) {
      deg -= 360.0;
    }
    while (deg < 0.0) {
      deg += 360.0;
    }
    return deg * deg2rad;
  }

  // Return the phase angle for the given date, in RADIANS.
  // Equation from Meeus eqn. 46.4.
  double getPhaseAngle(DateTime date) {
    // Time measured in Julian centuries from epoch J2000.0:
    DateTime tEpoch = DateTime(2000, 1, 1, 12);
    double t = (decimalYears(date) - decimalYears(tEpoch)) / 100.0;
    double t2 = t * t;
    double t3 = t2 * t;
    double t4 = t3 * t;

    // Mean elongation of the moon:
    double D = angle(297.8502042 +
        445267.1115168 * t -
        0.0016300 * t2 +
        t3 / 545868 +
        t4 / 113065000);
    // Sun's mean anomaly:
    double M =
    angle(357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000);
    // Moon's mean anomaly:
    double mPrime = angle(134.9634114 +
        477198.8676313 * t +
        0.0089970 * t2 -
        t3 / 3536000 +
        t4 / 14712000);

    return (angle(180 -
        (D / deg2rad) -
        6.289 * sin(mPrime) +
        2.100 * sin(M) -
        1.274 * sin(2 * D - mPrime) -
        0.658 * sin(2 * D) -
        0.214 * sin(2 * mPrime) -
        0.110 * sin(D)));
  }

  double decimalYears(DateTime date) {
    return date.millisecondsSinceEpoch.toDouble() /
        365.242191 /
        (24 * 60 * 60 * 1000);
  }

  double getTimeAsDecimalDay(DateTime date) {
    return date.millisecondsSinceEpoch.toDouble() / (24 * 60 * 60 * 1000);
  }
}