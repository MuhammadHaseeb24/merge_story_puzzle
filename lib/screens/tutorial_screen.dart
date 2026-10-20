import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../models/player_data.dart';
import '../services/save_service.dart';
import '../utils/constants.dart';
import '../widgets/item_tile.dart';
import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  final PlayerData player;

  const TutorialScreen({super.key, required this.player});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  int step = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Demo board for interactive tutorial
  List<List<MergeItem?>> demoBoard = List.generate(
    5,
        (_) => List.generate(5, (_) => null),
  );
  int demoSelectedRow = -1;
  int demoSelectedCol = -1;
  bool mergeDone = false;

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Welcome to Bloom & Bonds! 🌸',
      'body':
      'This is a Merge + Story game.\n\nYou will restore the beautiful Whispering Gardens by merging items… and unlock a heartfelt story along the way.',
      'emoji': '🏡',
    },
    {
      'title': 'How Merging Works',
      'body':
      '1. Tap any item on the board to select it.\n2. Then tap an adjacent matching item.\n3. They will merge into a higher-tier item!\n\nSame items next to each other = merge.',
      'emoji': '🔀',
    },
    {
      'title': 'Try It Yourself!',
      'body':
      'We placed two Seeds for you.\n\nTap the first Seed, then tap the second Seed next to it to merge them into a Sprout.',
      'emoji': '🌱',
      'interactive': true,
    },
    {
      'title': 'Great Job! ✨',
      'body':
      'You just created a Sprout!\n\nKeep merging to create Flowers, Bouquets, Benches, Fountains and more beautiful garden items.',
      'emoji': '🌿',
    },
    {
      'title': 'Energy System',
      'body':
      'Spawning new items costs Energy ⚡\n\nEnergy slowly regenerates over time (1 every 2 minutes).\n\nYou can also get free energy from the + button.',
      'emoji': '⚡',
    },
    {
      'title': 'Story Chapters',
      'body':
      'Every few merges unlock a new story chapter.\n\nFollow Lila and the secrets of Whispering Gardens.\nThere are 30 emotional chapters waiting for you!',
      'emoji': '📖',
    },
    {
      'title': 'You\'re Ready!',
      'body':
      'Tutorial complete.\n\nDummy mode has ended.\n\nNow go restore the gardens and discover the full story.\n\nHave fun! 💕',
      'emoji': '🎉',
    },
  ];

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

    // Prepare demo board for interactive step
    demoBoard[2][1] = MergeItem(type: ItemType.seed, level: 1);
    demoBoard[2][2] = MergeItem(type: ItemType.seed, level: 1);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (step == 2 && !mergeDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please merge the two Seeds first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (step < steps.length - 1) {
      setState(() => step++);
    } else {
      _finishTutorial();
    }
  }

  void _finishTutorial() async {
    widget.player.hasCompletedTutorial = true;
    await SaveService.save(widget.player);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _onDemoTap(int row, int col) {
    if (step != 2 || mergeDone) return;

    if (demoSelectedRow == -1) {
      if (demoBoard[row][col] != null) {
        setState(() {
          demoSelectedRow = row;
          demoSelectedCol = col;
        });
      }
      return;
    }

    if (demoSelectedRow == row && demoSelectedCol == col) {
      setState(() {
        demoSelectedRow = -1;
        demoSelectedCol = -1;
      });
      return;
    }

    final isAdjacent =
        (row - demoSelectedRow).abs() + (col - demoSelectedCol).abs() == 1;
    final selected = demoBoard[demoSelectedRow][demoSelectedCol];
    final target = demoBoard[row][col];

    if (isAdjacent &&
        selected != null &&
        target != null &&
        selected.canMergeWith(target)) {
      setState(() {
        demoBoard[row][col] = MergeItem(type: ItemType.sprout, level: 1);
        demoBoard[demoSelectedRow][demoSelectedCol] = null;
        demoSelectedRow = -1;
        demoSelectedCol = -1;
        mergeDone = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfect! You merged into a Sprout! 🌿'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (target != null) {
        setState(() {
          demoSelectedRow = row;
          demoSelectedCol = col;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final current = steps[step];
    final isInteractive = current['interactive'] == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 600 ? size.width * 0.15 : 24,
            vertical: 16,
          ),
          child: Column(
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(steps.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == step ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == step
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Big emoji
              ScaleTransition(
                scale: _pulseAnimation,
                child: Text(
                  current['emoji'] as String,
                  style: TextStyle(fontSize: isSmall ? 64 : 80),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                current['title'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isSmall ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        current['body'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 15 : 16,
                          height: 1.55,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (isInteractive) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(5, (r) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (c) {
                                  final isSelected =
                                      demoSelectedRow == r && demoSelectedCol == c;
                                  return ItemTile(
                                    item: demoBoard[r][c],
                                    isSelected: isSelected,
                                    size: size.width > 400 ? 56 : 48,
                                    onTap: () => _onDemoTap(r, c),
                                  );
                                }),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mergeDone
                              ? 'Awesome! Tap Next to continue →'
                              : 'Tap the two Seeds that are next to each other',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mergeDone
                                ? Colors.green.shade700
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Buttons
              const SizedBox(height: 12),
              if (step > 0 && step < steps.length - 1)
                TextButton(
                  onPressed: () => setState(() => step--),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    step == steps.length - 1
                        ? 'Start Playing for Real!'
                        : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (step < steps.length - 1)
                TextButton(
                  onPressed: _finishTutorial,
                  child: Text(
                    'Skip Tutorial',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 13,
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