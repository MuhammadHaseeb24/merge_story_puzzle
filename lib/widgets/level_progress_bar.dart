import 'package:flutter/material.dart';

import '../utils/constants.dart';

class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({
    super.key,
    required this.level,
    required this.progress,
  });

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Level $level, ${(progress * 100).round()} percent to next level',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(
            'Lv $level',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Lv ${level + 1}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
