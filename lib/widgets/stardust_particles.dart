import 'dart:math';
import 'package:flutter/material.dart';

class StardustParticles extends StatefulWidget {
  const StardustParticles({super.key});

  @override
  State<StardustParticles> createState() => _StardustParticlesState();
}

class _StardustParticlesState extends State<StardustParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StardustParticle> _particles = [];
  final Random _random = Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    if (_initialized) return;
    for (int i = 0; i < 40; i++) {
      _particles.add(StardustParticle.random(size, _random));
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initializeParticles(size);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Update particles
            for (final particle in _particles) {
              particle.update(size);
            }
            return CustomPaint(
              painter: StardustPainter(particles: _particles),
            );
          },
        );
      },
    );
  }
}

class StardustParticle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double alpha;
  late Color color;
  late double twinkleSpeed;
  double twinkleDirection = 1.0;

  StardustParticle.random(Size bounds, Random random) {
    reset(bounds, random);
  }

  void reset(Size bounds, Random random) {
    x = random.nextDouble() * bounds.width;
    y = random.nextDouble() * bounds.height;
    size = random.nextDouble() * 2.0 + 0.5;
    speedX = (random.nextDouble() - 0.5) * 0.3;
    speedY = (random.nextDouble() - 0.5) * 0.3;
    alpha = random.nextDouble() * 0.5 + 0.1;
    
    final colorVal = random.nextDouble();
    if (colorVal > 0.6) {
      color = const Color(0xFFA258F3); // magic lilac
    } else if (colorVal > 0.3) {
      color = const Color(0xFFFF9933); // sunset gold
    } else {
      color = Colors.white;
    }
    
    twinkleSpeed = random.nextDouble() * 0.01 + 0.005;
  }

  void update(Size bounds) {
    x += speedX;
    y += speedY;

    alpha += twinkleSpeed * twinkleDirection;
    if (alpha > 0.7 || alpha < 0.1) {
      twinkleDirection *= -1;
      alpha = alpha.clamp(0.1, 0.7);
    }

    if (y < -10) y = bounds.height + 10;
    if (y > bounds.height + 10) y = -10;
    if (x < -10) x = bounds.width + 10;
    if (x > bounds.width + 10) x = -10;
  }
}

class StardustPainter extends CustomPainter {
  final List<StardustParticle> particles;

  StardustPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StardustPainter oldDelegate) => true;
}
