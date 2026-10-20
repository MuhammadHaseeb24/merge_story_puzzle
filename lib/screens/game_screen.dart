import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';
import '../widgets/board_widget.dart';
import '../widgets/energy_bar.dart';
import 'home_screen.dart';
import 'story_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Auto-regenerate energy periodically
    Future.delayed(const Duration(seconds: 30), _tickEnergy);
  }

  void _tickEnergy() {
    if (!mounted) return;
    final controller = context.read<GameController>();
    controller.player.regenerateEnergy();
    controller.update();
    controller.save();
    Future.delayed(const Duration(seconds: 30), _tickEnergy);
  }

  void _onTileTap(int row, int col) {
    final controller = context.read<GameController>();
    final player = controller.player;
    final board = player.board;

    // If nothing selected → select this tile (if it has an item)
    if (player.selectedRow == -1) {
      if (board[row][col] != null) {
        setState(() {
          player.selectedRow = row;
          player.selectedCol = col;
        });
      }
      return;
    }

    // Same tile → deselect
    if (player.selectedRow == row && player.selectedCol == col) {
      setState(() {
        player.selectedRow = -1;
        player.selectedCol = -1;
      });
      return;
    }

    final selectedItem = board[player.selectedRow][player.selectedCol];
    final targetItem = board[row][col];

    // Check if adjacent
    final isAdjacent = (row - player.selectedRow).abs() +
            (col - player.selectedCol).abs() ==
        1;

    if (!isAdjacent) {
      // Select the new one instead
      if (targetItem != null) {
        setState(() {
          player.selectedRow = row;
          player.selectedCol = col;
        });
      }
      return;
    }

    // Attempt merge
    if (selectedItem != null &&
        targetItem != null &&
        selectedItem.canMergeWith(targetItem)) {
      final next = selectedItem.nextTier;
      if (next != null) {
        // Successful merge
        board[row][col] = next;
        board[player.selectedRow][player.selectedCol] = null;
        player.totalMerges++;
        player.unlockChapters();

        // Small coin reward
        player.coins += 5 + next.type.index * 2;

        setState(() {
          player.selectedRow = -1;
          player.selectedCol = -1;
        });

        controller.update();
        controller.save();

        // Celebration feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merged into ${next.displayName}! ✨'),
            backgroundColor: AppColors.success,
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Check if new chapter unlocked
        final newlyUnlocked = player.chapters
            .where((c) => c.isUnlocked && c.requiredMerges == player.totalMerges)
            .toList();
        if (newlyUnlocked.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('New Chapter Unlocked! 📖'),
                  content: Text('"${newlyUnlocked.first.title}" is now available.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StoryScreen(chapters: player.chapters),
                          ),
                        );
                      },
                      child: const Text('Read Now'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Later'),
                    ),
                  ],
                ),
              );
            }
          });
        }
      } else {
        // Max tier
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is already the highest tier!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Not matching → just select the new tile
      if (targetItem != null) {
        setState(() {
          player.selectedRow = row;
          player.selectedCol = col;
        });
      }
    }
  }

  void _spawnItem() {
    final controller = context.read<GameController>();
    final player = controller.player;

    if (!player.spendEnergy(GameConstants.energyCostSpawn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough energy! Wait or add more.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Find empty cells
    final empties = <Point<int>>[];
    for (int r = 0; r < GameConstants.boardSize; r++) {
      for (int c = 0; c < GameConstants.boardSize; c++) {
        if (player.board[r][c] == null) {
          empties.add(Point(r, c));
        }
      }
    }

    if (empties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Board is full! Merge some items first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      player.addEnergy(GameConstants.energyCostSpawn); // refund
      return;
    }

    final spot = empties[_random.nextInt(empties.length)];

    // Weighted spawn: mostly low tiers
    final roll = _random.nextDouble();
    ItemType type;
    if (roll < 0.55) {
      type = ItemType.seed;
    } else if (roll < 0.85) {
      type = ItemType.sprout;
    } else {
      type = ItemType.flower;
    }

    player.board[spot.x][spot.y] = MergeItem(type: type, level: 1);

    setState(() {});
    controller.update();
    controller.save();
  }

  void _addEnergy() {
    final controller = context.read<GameController>();
    // In a real game this would show rewarded ad or IAP
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Get More Energy'),
        content: const Text(
          'In the full game this would open a rewarded ad or energy pack purchase.\n\nFor this prototype you receive +15 energy for free.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.player.addEnergy(15);
              controller.update();
              controller.save();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('+15 Energy!'),
                  backgroundColor: AppColors.energy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Claim Free Energy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final player = controller.player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Whispering Gardens',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryScreen(chapters: player.chapters),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              EnergyBar(
                energy: player.energy,
                maxEnergy: player.maxEnergy,
                onAddEnergy: _addEnergy,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Lv ${player.currentLevel}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Merges: ${player.totalMerges}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Coins: ${player.coins} 💰',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: BoardWidget(
                    board: player.board,
                    selectedRow: player.selectedRow,
                    selectedCol: player.selectedCol,
                    onTileTap: _onTileTap,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap an item, then tap an adjacent matching item to merge',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _spawnItem,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(
                    'Spawn Item  (-1 Energy)',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
