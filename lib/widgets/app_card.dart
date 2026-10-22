import 'package:flutter/material.dart';

import 'raised_surface.dart';

/// White card with a 3D extruded edge.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return RaisedSurface(
      color: Colors.white,
      radius: 22,
      depth: 5,
      padding: padding,
      child: child,
    );
  }
}
