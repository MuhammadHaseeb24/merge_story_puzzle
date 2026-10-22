import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/constants.dart';
import 'raised_surface.dart';

/// A board cell: a sunken socket holding a raised 3D tile. Sizes everything
/// from the space it is given.
class ItemTile extends StatefulWidget {
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
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.item;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final e = constraints.biggest.shortestSide;
            return Padding(
              padding: EdgeInsets.all(e * 0.04),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(e * 0.24),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFD9C6E8), Color(0xFFF1E7F8)],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(e * 0.03),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.elasticOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      layoutBuilder: (currentChild, previousChildren) => Stack(
                        fit: StackFit.expand,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      ),
                      child: current == null
                          ? const SizedBox.expand(key: ValueKey('empty'))
                          : _Face(
                              key: ValueKey(current.id),
                              item: current,
                              selected: widget.isSelected,
                              pressed: _down,
                              extent: e,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    super.key,
    required this.item,
    required this.selected,
    required this.pressed,
    required this.extent,
  });

  final MergeItem item;
  final bool selected;
  final bool pressed;
  final double extent;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: selected ? const Offset(0, -0.06) : Offset.zero,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: selected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: RaisedSurface(
          color: item.color,
          radius: extent * 0.22,
          depth: extent * 0.09,
          pressed: pressed,
          glow: selected ? AppColors.primary : null,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(extent * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.emoji,
                      style: TextStyle(
                        fontSize: extent * 0.40,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: extent * 0.08,
                            offset: Offset(0, extent * 0.05),
                          ),
                        ],
                      ),
                    ),
                    if (extent >= 56)
                      Text(
                        item.displayName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: extent * 0.13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
