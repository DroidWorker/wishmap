// Функция для добавления закругленных углов к пути
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

// Функция для добавления закругленных углов к прямоугольному пути
// Функция для смещения начальной точки пути на 20 пикселей вверх
Path moveStartPointUp(Path path, double offset) {
  Path newPath = Path();
  bool firstPoint = true;

  for (PathMetric pathMetric in path.computeMetrics()) {
    Tangent? tangent = pathMetric.getTangentForOffset(0);
    Offset? startPoint = tangent?.position;
    if (startPoint != null) {
      // Смещаем начальную точку на offset вверх
      newPath.moveTo(startPoint.dx, startPoint.dy - offset);
    }

    for (double distance = 0.0; distance < pathMetric.length; distance += 1.0) {
      tangent = pathMetric.getTangentForOffset(distance);
      if (tangent != null) {
        newPath.lineTo(tangent.position.dx, tangent.position.dy);
      }
    }
  }
  return newPath;
}

// Функция для смещения начальной точки пути на 20 пикселей вверх и создания буквы L с закругленным углом
Path moveStartPointUpAndCreateLetterL(Path path, double offset, double cornerRadius) {
  Path newPath = Path();
  Offset? previousPoint;

  for (PathMetric pathMetric in path.computeMetrics()) {
    Tangent? tangent = pathMetric.getTangentForOffset(0);
    Offset? startPoint = tangent?.position;
    if (startPoint != null) {
      // Смещаем начальную точку на offset вверх
      newPath.moveTo(startPoint.dx, startPoint.dy - offset);
      previousPoint = Offset(startPoint.dx, startPoint.dy - offset);
    }
    tangent = pathMetric.getTangentForOffset(pathMetric.length-1);
    final endpoint = tangent?.position;
    print("jjjjjjjjjjjjjj${pathMetric.length}");
    if(endpoint!=null&&previousPoint!=null) {
      newPath.lineTo(previousPoint.dx, endpoint.dy);
      newPath.addArc(Rect.fromPoints(Offset(previousPoint.dx, endpoint.dy-3), Offset(previousPoint.dx+6, endpoint.dy+3)), 45, 90);
    }
  }

  // Рисуем горизонтальную линию для создания буквы L
  /*if (previousPoint != null) {
    newPath.moveTo(previousPoint.dx, previousPoint.dy);
    newPath.lineTo(previousPoint.dx + 50.0, previousPoint.dy);
  }*/

  return newPath;
}