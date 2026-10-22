import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isCompactWidth => screenSize.width < Breakpoints.compact;
  bool get isShortHeight => screenSize.height < 640;
}

/// Centers content and caps its width so layouts stay readable on tablets,
/// desktop and web.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
