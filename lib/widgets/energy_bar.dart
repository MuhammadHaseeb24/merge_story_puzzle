import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'app_card.dart';

class EnergyBar extends StatelessWidget {
  const EnergyBar({
    super.key,
    required this.energy,
    required this.maxEnergy,
    this.nextEnergyIn,
    this.onAddEnergy,
  });

  final int energy;
  final int maxEnergy;
  final ValueListenable<Duration?>? nextEnergyIn;
  final VoidCallback? onAddEnergy;

  static String _format(Duration d) {
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (energy / maxEnergy).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.energy, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Energy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$energy / $maxEnergy',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.energy.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.energy),
                  ),
                ),
                if (nextEnergyIn != null)
                  ValueListenableBuilder<Duration?>(
                    valueListenable: nextEnergyIn!,
                    builder: (context, remaining, _) {
                      final text = remaining == null
                          ? 'Fully charged'
                          : 'Next +1 in ${_format(remaining)}';
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            tooltip: 'Get more energy',
            onPressed: onAddEnergy,
            style: IconButton.styleFrom(backgroundColor: AppColors.energy),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
