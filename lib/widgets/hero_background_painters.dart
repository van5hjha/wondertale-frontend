import 'package:flutter/material.dart';

class DottedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA258F3).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    const double spacing = 32.0;
    const double radius = 0.75;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WarmNebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radiusValue = size.width * 0.5;

    // 1. Radial gradient at 30% 40% (Sunset Gold)
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF9933).withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.4),
        radius: radiusValue,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60.0);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    // 2. Radial gradient at 70% 60% (Magic Lilac)
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFA258F3).withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.6),
        radius: radiusValue,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60.0);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    // 3. Vibrant content-side backdrop (Linear Gradient behind the left content)
    final paint3 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFA258F3).withOpacity(0.2), // magic-lilac
          const Color(0xFFFF9933).withOpacity(0.2), // sunset-gold
          const Color(0xFF812DC6).withOpacity(0.2), // secondary
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(
        0,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.8,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100.0);

    canvas.drawRect(Rect.fromLTWH(
      -40,
      size.height * 0.1 - 40,
      size.width * 0.5 + 80,
      size.height * 0.8 + 80,
    ), paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StampEdgePainter extends CustomPainter {
  final Color fillColor;

  StampEdgePainter({required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant StampEdgePainter oldDelegate) => oldDelegate.fillColor != fillColor;
}
