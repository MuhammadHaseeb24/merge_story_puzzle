import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF7E57C2);       // Soft purple
  static const secondary = Color(0xFF26A69A);     // Teal
  static const background = Color(0xFFF3E5F5);    // Light lavender
  static const surface = Color(0xFFFFFFFF);
  static const energy = Color(0xFFFFB74D);        // Warm orange
  static const success = Color(0xFF66BB6A);
  static const textPrimary = Color(0xFF4A148C);
  static const textSecondary = Color(0xFF6A1B9A);
}

class GameConstants {
  static const int boardSize = 5;
  static const int energyCostSpawn = 1;
  static const int energyCostMerge = 0; // free once items exist
  static const int maxEnergy = 30;
  static const int energyRegenMinutes = 2; // 1 energy per 2 min
}
