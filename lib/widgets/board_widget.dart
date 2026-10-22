import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/item.dart';
import '../utils/constants.dart';
import 'item_tile.dart';
import 'raised_surface.dart';

/// Merge board drawn as a thick slab tilted back in perspective.
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    required this.selected,
    required this.onTileTap,
  });

  final List<List<MergeItem?>> board;
  final Cell? selected;
  final void Function(int row, int col) onTileTap;

  static const double _pad = 10;
  static const double _depth = 14;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity;
        final grid = math.max(
          0.0,
          math.min(
            math.min(constraints.maxWidth - _pad * 2, maxH - _pad * 2 - _depth - 8),
            GameConstants.maxBoardSide,
          ),
        );

        final slab = SizedBox(
          width: grid + _pad * 2,
          height: grid + _pad * 2 + _depth,
          child: RaisedSurface(
            color: const Color(0xFFFBF5FE),
            radius: 28,
            depth: _depth,
            padding: const EdgeInsets.all(_pad),
            child: Column(
              children: [
                for (var r = 0; r < GameConstants.boardSize; r++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < GameConstants.boardSize; c++)
                          Expanded(
                            child: ItemTile(
                              item: board[r][c],
                              isSelected: selected == (row: r, col: c),
                              semanticLabel:
                                  'Row ${r + 1}, column ${c + 1}: ${board[r][c]?.displayName ?? 'empty'}',
                              onTap: () => onTileTap(r, c),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );

        return Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateX(0.30),
            child: slab,
          ),
        );
      },
    );
  }
}
