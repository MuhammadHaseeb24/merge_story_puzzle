import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/cell.dart';
import '../models/item.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';
import '../widgets/button_3d.dart';
import '../widgets/floating_3d.dart';
import '../widgets/garden_background.dart';
import '../utils/responsive.dart';
import '../utils/ui_helpers.dart';
import '../widgets/board_widget.dart';

class _TutorialStep {
  const _TutorialStep({
    required this.title,
    required this.body,
    required this.emoji,
    this.interactive = false,
  });

  final String title;
  final String body;
  final String emoji;
  final bool interactive;
}

const List<_TutorialStep> _steps = [
  _TutorialStep(
    title: 'Welcome to Bloom & Bonds! 🌸',
    body:
        'This is a Merge + Story game.\n\nYou will restore the beautiful Whispering Gardens by merging items… and unlock a heartfelt story along the way.',
    emoji: '🏡',
  ),
  _TutorialStep(
    title: 'How Merging Works',
    body:
        '1. Tap any item on the board to select it.\n2. Tap an adjacent matching item to merge them into a higher tier.\n3. Tap an empty tile to move the item there, or a different neighbour to swap places.',
    emoji: '🔀',
  ),
  _TutorialStep(
    title: 'Try It Yourself!',
    body:
        'We placed two Seeds for you.\n\nTap the first Seed, then tap the Seed next to it to merge them into a Sprout.',
    emoji: '🌱',
    interactive: true,
  ),
  _TutorialStep(
    title: 'Great Job! ✨',
    body:
        'You just created a Sprout!\n\nKeep merging to create Flowers, Bouquets, Benches, Fountains and more beautiful garden items.',
    emoji: '🌿',
  ),
  _TutorialStep(
    title: 'Energy System',
    body:
        'Spawning new items costs Energy ⚡\n\nEnergy slowly regenerates over time (1 every 2 minutes).\n\nYou can also refill it with the + button.',
    emoji: '⚡',
  ),
  _TutorialStep(
    title: 'Story Chapters',
    body:
        'Merging unlocks new story chapters as you go.\n\nFollow Lila and the secrets of Whispering Gardens.\nThere are 30 emotional chapters waiting for you!',
    emoji: '📖',
  ),
  _TutorialStep(
    title: "You're Ready!",
    body:
        'Tutorial complete.\n\nNow go restore the gardens and discover the full story.\n\nHave fun! 💕',
    emoji: '🎉',
  ),
];

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<List<MergeItem?>> _demoBoard = PlayerData.createEmptyBoard();
  Cell? _demoSelected;
  bool _mergeDone = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _demoBoard[2][1] = MergeItem(type: ItemType.seed);
    _demoBoard[2][2] = MergeItem(type: ItemType.seed);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 2 && !_mergeDone) {
      showAppToast(context, 'Please merge the two Seeds first!');
      return;
    }
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() => context.read<GameController>().completeTutorial();

  void _onDemoTap(int row, int col) {
    if (_mergeDone) return;

    final tapped = _demoBoard[row][col];
    final sel = _demoSelected;

    if (sel == null) {
      if (tapped != null) setState(() => _demoSelected = (row: row, col: col));
      return;
    }
    if (sel.row == row && sel.col == col) {
      setState(() => _demoSelected = null);
      return;
    }

    final source = _demoBoard[sel.row][sel.col];
    final adjacent = (row - sel.row).abs() + (col - sel.col).abs() == 1;

    if (adjacent && source != null && tapped != null && source.canMergeWith(tapped)) {
      setState(() {
        _demoBoard[row][col] = MergeItem(type: ItemType.sprout);
        _demoBoard[sel.row][sel.col] = null;
        _demoSelected = null;
        _mergeDone = true;
      });
      showAppToast(
        context,
        'Perfect! You merged into a Sprout! 🌿',
        color: AppColors.success,
      );
    } else if (tapped != null) {
      setState(() => _demoSelected = (row: row, col: col));
    } else {
      setState(() => _demoSelected = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _steps[_step];
    final small = context.isShortHeight;
    final isLast = _step == _steps.length - 1;

    return Scaffold(
      body: GardenBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            maxWidth: 560,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _step ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _step
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Floating3D(
                                  child: Text(
                                    current.emoji,
                                    style: TextStyle(fontSize: small ? 56 : 80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                current.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: small ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                current.body,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: small ? 15 : 16,
                                  height: 1.55,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              if (current.interactive) ...[
                                const SizedBox(height: 20),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 340),
                                  child: BoardWidget(
                                    board: _demoBoard,
                                    selected: _demoSelected,
                                    onTileTap: _onDemoTap,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _mergeDone
                                      ? 'Awesome! Tap Next to continue →'
                                      : 'Tap the two Seeds that are next to each other',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _mergeDone
                                        ? Colors.green.shade700
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Button3D(
                  label: isLast ? 'Start Playing!' : 'Next',
                  icon: isLast
                      ? Icons.celebration_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_step > 0 && !isLast)
                        TextButton(
                          onPressed: () => setState(() => _step--),
                          child: const Text('Back'),
                        ),
                      if (!isLast)
                        TextButton(
                          onPressed: _finish,
                          child: const Text('Skip tutorial'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
