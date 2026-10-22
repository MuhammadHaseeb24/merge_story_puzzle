import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows a single floating snackbar, replacing any visible one.
void showAppToast(
  BuildContext context,
  String message, {
  Color? color,
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final width = math.min(MediaQuery.sizeOf(context).width - 32, 420.0);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        width: width,
        duration: const Duration(milliseconds: 1800),
        action: action,
      ),
    );
}
