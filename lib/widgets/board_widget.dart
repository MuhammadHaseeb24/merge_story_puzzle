import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/item.dart';
import '../utils/constants.dart';
import 'item_tile.dart';

/// Square merge board that fills the space it is given (up to a max size).
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.hasBoundedHeight ? constraints.maxHeight : maxW;
        final side = math.min(math.min(maxW, maxH), GameConstants.maxBoardSide);

        return Center(
          child: Container(
            width: side,
            height: side,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
      },
    );
  }
}
