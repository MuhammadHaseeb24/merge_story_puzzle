import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF7E57C2); // Soft purple
  static const secondary = Color(0xFF26A69A); // Teal
  static const background = Color(0xFFF3E5F5); // Light lavender
  static const surface = Color(0xFFFFFFFF);
  static const energy = Color(0xFFFFB74D); // Warm orange
  static const success = Color(0xFF66BB6A);
  static const danger = Color(0xFFE57373);
  static const textPrimary = Color(0xFF4A148C);
  static const textSecondary = Color(0xFF6A1B9A);
  static const textMuted = Color(0xFF757575);
  static const parchment = Color(0xFFFFF8E1);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8EEFB), Color(0xFFEBD7F2)],
  );
}

class GameConstants {
  GameConstants._();

  static const int boardSize = 5;
  static const double maxBoardSide = 560;

  static const int energyCostSpawn = 1;
  static const int maxEnergy = 30;
  static const int energyOvercap = 50; // bonus energy allowed above max
  static const int energyRegenMinutes = 2; // 1 energy per 2 min
  static const int freeEnergyAmount = 15;

  static const int startingCoins = 100;
  static const int mergeCoinBase = 5;
  static const int mergeCoinPerTier = 2;
  static const int masterpieceBonus = 100;

  // Spawn weights (cumulative): seed 55%, sprout 30%, flower 15%.
  static const double seedChance = 0.55;
  static const double sproutChance = 0.30;

  static const Duration saveDebounce = Duration(milliseconds: 400);
}
