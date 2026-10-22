import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';
import '../widgets/level_progress_bar.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/stat_chip.dart';
import 'game_screen.dart';
import 'story_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final player = controller.player;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= Breakpoints.medium;
              final hero = _Hero(player: player);
              final actions = _Actions(player: player);

              return Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(0, constraints.maxHeight - 64),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: wide ? 980 : 520),
                            child: wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(child: hero),
                                      const SizedBox(width: 48),
                                      Expanded(child: actions),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      hero,
                                      const SizedBox(height: 24),
                                      actions,
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 8,
                    child: IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_outlined),
                      color: AppColors.textPrimary,
                      onPressed: () => _openSettings(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bloom & Bonds',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: context.screenSize.width < 360 ? 28 : 34,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Merge • Story • Heart',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌸 Whispering Gardens',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Restore the abandoned gardens by merging items and unlock the emotional story of Lila.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      icon: Icons.bolt,
                      value: '${player.energy}',
                      label: 'Energy',
                    ),
                  ),
                  Expanded(
                    child: StatChip(
                      icon: Icons.trending_up,
                      value: 'Lv ${player.currentLevel}',
                      label: 'Level',
                    ),
                  ),
                  Expanded(
                    child: StatChip(
                      icon: Icons.merge,
                      value: '${player.totalMerges}',
                      label: 'Merges',
                    ),
                  ),
                  Expanded(
                    child: StatChip(
                      icon: Icons.menu_book,
                      value: '${player.unlockedChapterCount}',
                      label: 'Chapters',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LevelProgressBar(
                level: player.currentLevel,
                progress: player.levelProgress,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    final next = player.nextLockedChapter;
    final remaining =
        next == null ? 0 : math.max(0, next.requiredMerges - player.totalMerges);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (next != null) ...[
          Text(
            'Next chapter in $remaining ${remaining == 1 ? 'merge' : 'merges'}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const GameScreen()),
          ),
          child: Text(
            player.totalMerges == 0 ? 'Start Restoring' : 'Continue Restoring',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const StoryScreen()),
          ),
          child: Text(
            'Read Story Chapters (${player.unlockedChapterCount}/${player.chapters.length})',
          ),
        ),
      ],
    );
  }
}
