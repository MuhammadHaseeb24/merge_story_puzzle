import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft animated gradient with drifting glow orbs.
class GardenBackground extends StatefulWidget {
  const GardenBackground({super.key, required this.child});

  final Widget child;

  @override
  State<GardenBackground> createState() => _GardenBackgroundState();
}

class _GardenBackgroundState extends State<GardenBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(painter: _BgPainter(_c.value)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Orb {
  const _Orb(this.x, this.y, this.r, this.phase, this.speed, this.color);
  final double x, y, r, phase;
  final int speed;
  final Color color;
}

const _orbs = <_Orb>[
  _Orb(0.15, 0.12, 0.34, 0.0, 1, Color(0xFFFFB3E6)),
  _Orb(0.85, 0.20, 0.30, 0.3, 2, Color(0xFFB39DFF)),
  _Orb(0.25, 0.55, 0.28, 0.6, 1, Color(0xFF9FE3D6)),
  _Orb(0.80, 0.65, 0.36, 0.1, 1, Color(0xFFFFCFA3)),
  _Orb(0.50, 0.90, 0.32, 0.8, 2, Color(0xFFD1A3FF)),
  _Orb(0.55, 0.30, 0.20, 0.5, 3, Color(0xFFFFF3B0)),
];

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBEFFF), Color(0xFFE9D5F5), Color(0xFFD6C0EE)],
        ).createShader(rect),
    );

    for (final o in _orbs) {
      final a = 2 * math.pi * (t * o.speed + o.phase);
      final center = Offset(
        size.width * (o.x + 0.05 * math.sin(a)),
        size.height * (o.y + 0.035 * math.cos(a)),
      );
      final radius = size.shortestSide * o.r;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [o.color.withValues(alpha: 0.55), o.color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
