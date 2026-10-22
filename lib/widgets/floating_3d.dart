import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Gently bobs and rotates its child in 3D space (perspective + rotateY/X).
class Floating3D extends StatefulWidget {
  const Floating3D({super.key, required this.child, this.amplitude = 8});

  final Widget child;
  final double amplitude;

  @override
  State<Floating3D> createState() => _Floating3DState();
}

class _Floating3DState extends State<Floating3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final a = _c.value * 2 * math.pi;
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(0.5 * math.sin(a))
          ..rotateX(0.14 * math.cos(a));
        return Transform.translate(
          offset: Offset(0, -widget.amplitude * math.sin(a)),
          child: Transform(alignment: Alignment.center, transform: m, child: child),
        );
      },
    );
  }
}
