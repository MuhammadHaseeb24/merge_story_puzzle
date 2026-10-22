import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/game_controller.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tutorial_screen.dart';
import 'theme/app_theme.dart';

class BloomAndBondsApp extends StatelessWidget {
  const BloomAndBondsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom & Bonds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Keep layouts stable when users change system font size.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppGate(),
    );
  }
}

/// Decides which root screen to show: splash -> tutorial (first run) -> home.
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<GameController, bool>((c) => c.loaded);
    if (!loaded) return const SplashScreen();

    final tutorialDone = context
        .select<GameController, bool>((c) => c.player.hasCompletedTutorial);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: tutorialDone
          ? const HomeScreen(key: ValueKey('home'))
          : const TutorialScreen(key: ValueKey('tutorial')),
    );
  }
}
