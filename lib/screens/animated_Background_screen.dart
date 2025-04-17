import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Create animation controller for continuous animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * 400,
            _random.nextDouble() * 800,
          ),
          size: 5 + _random.nextDouble() * 15,
          speed: 0.2 + _random.nextDouble() * 0.8,
          angle: _random.nextDouble() * pi * 2,
          color: Colors.white.withOpacity(0.1 + _random.nextDouble() * 0.2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withBlue(180),
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withRed(180),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              animation: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  Offset position;
  double size;
  double speed;
  double angle;
  Color color;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calculate new position based on animation value
      final offset = Offset(
        (particle.position.dx +
                cos(particle.angle) * particle.speed * animation * 100) %
            size.width,
        (particle.position.dy +
                sin(particle.angle) * particle.speed * animation * 100) %
            size.height,
      );

      // Draw the particle
      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(offset, particle.size, paint);

      // Draw connecting lines between nearby particles
      for (var other in particles) {
        final distance =
            (offset -
                    Offset(
                      (other.position.dx +
                              cos(other.angle) *
                                  other.speed *
                                  animation *
                                  100) %
                          size.width,
                      (other.position.dy +
                              sin(other.angle) *
                                  other.speed *
                                  animation *
                                  100) %
                          size.height,
                    ))
                .distance;

        if (distance < 100) {
          canvas.drawLine(
            offset,
            Offset(
              (other.position.dx +
                      cos(other.angle) * other.speed * animation * 100) %
                  size.width,
              (other.position.dy +
                      sin(other.angle) * other.speed * animation * 100) %
                  size.height,
            ),
            Paint()
              ..color = particle.color.withOpacity(0.2 * (1 - distance / 100))
              ..strokeWidth = 1,
          );
        }
      }
    }

    // Add a subtle wave effect
    final wavePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5 + sin(animation * 2 * pi) * 50);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            sin((animation * 2 * pi) + (i / size.width * 4 * pi)) * 50,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
