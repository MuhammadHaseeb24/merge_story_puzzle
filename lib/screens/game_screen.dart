import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/story_chapter.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../utils/ui_helpers.dart';
import '../widgets/app_card.dart';
import '../widgets/board_widget.dart';
import '../widgets/energy_bar.dart';
import '../widgets/level_progress_bar.dart';
import '../widgets/stat_chip.dart';
import 'story_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final player = controller.player;

    final board = BoardWidget(
      board: player.board,
      selected: controller.selected,
      onTileTap: (row, col) => _onTileTap(context, row, col),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Whispering Gardens',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Story chapters',
            icon: const Icon(Icons.menu_book),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const StoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720 &&
                constraints.maxWidth > constraints.maxHeight * 1.15;

            if (wide) {
              // Tablet / landscape: board on the left, controls on the right.
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: board),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 340,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatusPanel(controller: controller, compact: false),
                            const SizedBox(height: 16),
                            _SpawnPanel(showHint: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final compact = context.isShortHeight;
            return ResponsiveCenter(
              maxWidth: 640,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatusPanel(controller: controller, compact: compact),
                  const SizedBox(height: 12),
                  Expanded(child: board),
                  const SizedBox(height: 12),
                  _SpawnPanel(showHint: !compact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Panels

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.controller, required this.compact});

  final GameController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnergyBar(
          energy: player.energy,
          maxEnergy: player.maxEnergy,
          nextEnergyIn: controller.nextEnergyIn,
          onAddEnergy: () => _showEnergyDialog(context),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
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
                      icon: Icons.monetization_on_outlined,
                      value: '${player.coins}',
                      label: 'Coins',
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 12),
                LevelProgressBar(
                  level: player.currentLevel,
                  progress: player.levelProgress,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SpawnPanel extends StatelessWidget {
  const _SpawnPanel({required this.showHint});

  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHint) ...[
          Text(
            'Tap an item, then tap an adjacent match to merge — an empty tile to move it, or a different neighbour to swap.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          onPressed: () => _onSpawn(context),
          icon: const Icon(Icons.add_circle_outline),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
          ),
          label: Text('Spawn Item  (-${GameConstants.energyCostSpawn} ⚡)'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Handlers

void _onTileTap(BuildContext context, int row, int col) {
  final controller = context.read<GameController>();
  final result = controller.onTileTap(row, col);

  if (result.newChapters.isNotEmpty) {
    _showChapterUnlocked(context, result.newChapters.first);
    return;
  }

  switch (result.outcome) {
    case TapOutcome.merged:
      showAppToast(
        context,
        'Merged into ${result.item!.displayName}! +${result.coinsEarned} 💰',
        color: AppColors.success,
      );
    case TapOutcome.masterpiece:
      showAppToast(
        context,
        'Garden masterpiece complete! +${result.coinsEarned} 💰',
        color: AppColors.success,
      );
    case TapOutcome.ignored:
    case TapOutcome.selected:
    case TapOutcome.deselected:
    case TapOutcome.moved:
    case TapOutcome.swapped:
      break;
  }
}

void _onSpawn(BuildContext context) {
  final controller = context.read<GameController>();
  switch (controller.spawn()) {
    case SpawnOutcome.spawned:
      break;
    case SpawnOutcome.noEnergy:
      showAppToast(
        context,
        'Not enough energy! Wait for it to recharge or refill.',
        color: AppColors.danger,
        action: SnackBarAction(
          label: 'Refill',
          textColor: Colors.white,
          onPressed: () => _showEnergyDialog(context),
        ),
      );
    case SpawnOutcome.boardFull:
      showAppToast(context, 'Board is full! Merge or move items first.');
  }
}

void _showEnergyDialog(BuildContext context) {
  final controller = context.read<GameController>();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Refill Energy'),
      content: const Text(
        'In the full release this opens a rewarded ad or an energy pack.\n\n'
        'For this build you can claim +${GameConstants.freeEnergyAmount} energy for free.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            controller.claimFreeEnergy();
            Navigator.pop(ctx);
            showAppToast(
              context,
              '+${GameConstants.freeEnergyAmount} Energy!',
              color: AppColors.energy,
            );
          },
          child: const Text('Claim free energy'),
        ),
      ],
    ),
  );
}

void _showChapterUnlocked(BuildContext context, StoryChapter chapter) {
  final navigator = Navigator.of(context);
  final controller = context.read<GameController>();
  final number =
      controller.player.chapters.indexWhere((c) => c.id == chapter.id) + 1;

  showModalBottomSheet<void>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(chapter.characterEmoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(
              'New chapter unlocked! 📖',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chapter $number · ${chapter.title}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChapterReader(
                            chapter: chapter,
                            number: number,
                          ),
                        ),
                      );
                    },
                    child: const Text('Read now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
