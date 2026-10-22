import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../utils/constants.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  Future<void> _confirmReset(
    BuildContext context,
    GameController controller,
  ) async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This will erase all progress and restart the tutorial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      navigator.pop();
      await controller.resetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Haptic feedback'),
              subtitle: const Text('Vibrate lightly when you tap and merge'),
              value: controller.player.hapticsEnabled,
              onChanged: controller.setHaptics,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt, color: AppColors.danger),
              title: const Text('Reset progress'),
              onTap: () => _confirmReset(context, controller),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bloom & Bonds · v1.1.0',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
