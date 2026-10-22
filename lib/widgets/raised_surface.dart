import 'dart:math' as math;

import 'package:flutter/material.dart';

Color shadeColor(Color c, double amount) {
  final h = HSLColor.fromColor(c);
  return h.withLightness(math.min(1.0, math.max(0.0, h.lightness - amount))).toColor();
}

Color tintColor(Color c, double amount) => shadeColor(c, -amount);

/// A "3D" block: a lit top face sitting on a darker extruded side. Pressing it
/// pushes the face down towards the base.
class RaisedSurface extends StatelessWidget {
  const RaisedSurface({
    super.key,
    required this.child,
    required this.color,
    this.radius = 20,
    this.depth = 6,
    this.pressed = false,
    this.padding = EdgeInsets.zero,
    this.glow,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double depth;
  final bool pressed;
  final EdgeInsetsGeometry padding;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final d = pressed ? depth * 0.3 : depth;
    final r = BorderRadius.circular(radius);
    const duration = Duration(milliseconds: 90);

    return AnimatedPadding(
      duration: duration,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(top: depth - d),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: shadeColor(color, 0.2),
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: glow == null
                  ? Colors.black.withValues(alpha: 0.18)
                  : glow!.withValues(alpha: 0.6),
              blurRadius: glow == null ? 12 : 20,
              offset: Offset(0, d + 3),
            ),
          ],
        ),
        child: AnimatedPadding(
          duration: duration,
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: d),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [tintColor(color, 0.14), color],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
