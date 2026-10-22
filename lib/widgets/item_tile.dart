import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/constants.dart';

/// A single board cell. Sizes everything from the space it is given, so it
/// scales cleanly from small phones to tablets and desktop windows.
class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.semanticLabel,
  });

  final MergeItem? item;
  final bool isSelected;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final current = item;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final extent = constraints.biggest.shortestSide;
            final fill = current == null
                ? Colors.grey.shade100
                : current.color.withValues(alpha: 0.85);
            final borderColor = isSelected
                ? AppColors.primary
                : (current == null ? Colors.grey.shade300 : current.color);

            return AnimatedScale(
              scale: isSelected ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(extent * 0.04),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(extent * 0.2),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: current == null
                      ? const SizedBox.expand(key: ValueKey('empty'))
                      : _TileContent(
                          key: ValueKey(current.id),
                          item: current,
                          extent: extent,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TileContent extends StatelessWidget {
  const _TileContent({super.key, required this.item, required this.extent});

  final MergeItem item;
  final double extent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(extent * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.emoji, style: TextStyle(fontSize: extent * 0.42)),
              if (extent >= 56)
                Text(
                  item.displayName,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: extent * 0.14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
