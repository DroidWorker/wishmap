import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/svg.dart';

class RadialChart extends StatelessWidget {
  final List<int> filledSections;
  final int totalSections;

  const RadialChart({super.key,
    required this.filledSections,
    this.totalSections = 11, // Default total rings
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: CustomPaint(
              size: const Size(300, 300),
              painter: RadialChartPainter(
                filledSections: filledSections,
                totalSections: totalSections,
              ),
            ),
          ),
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/icons/back_diagram.svg',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

class RadialChartPainter extends CustomPainter {
  final List<int> filledSections;
  final int totalSections;

  RadialChartPainter({
    required this.filledSections,
    required this.totalSections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final sectorAngle = 2 * pi / filledSections.length;
    final sectionWidth = (radius / totalSections) - 1; // Adjusted for spacing

    final colors = [
      const Color(0xFF00EA8C),
      const Color(0xFFFF0000),
      const Color(0xFF70D9FF),
      const Color(0xFF0077FF),
      const Color(0xFFFF9500),
      const Color(0xFF007304),
      const Color(0xFFFFE331),
      const Color(0xFFAE42F6),
    ];

    for (int i = 0; i < filledSections.length; i++) {
      final color = colors[i % colors.length];

      for (int j = 1; j <= filledSections[i]+1; j++) {
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white,
              color.withOpacity(j / totalSections),
            ],
            stops: [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: radius,
            ),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = sectionWidth;

        final ringRadius = (j - 1) * (radius / totalSections) + sectionWidth / 2 + 1; // Add spacing

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: ringRadius),
          (-pi / 2 + i * sectorAngle)+0.01,
          sectorAngle - 0.02, // Add spacing between sectors
          false,
          paint,
        );
      }
    }
    var cPaint = Paint()
      ..color = Colors.white;
    canvas.drawCircle(center, sectionWidth, cPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}