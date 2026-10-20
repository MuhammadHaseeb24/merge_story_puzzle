import 'package:flutter/material.dart';
import '../models/item.dart';
import '../utils/constants.dart';
import 'item_tile.dart';

class BoardWidget extends StatelessWidget {
  final List<List<MergeItem?>> board;
  final int selectedRow;
  final int selectedCol;
  final Function(int row, int col) onTileTap;

  const BoardWidget({
    super.key,
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Fully responsive: never too big on tablets, never too small on phones
    final maxBoardWidth = size.width > 500 ? 420.0 : size.width - 32;
    final boardWidth = maxBoardWidth.clamp(280.0, 420.0);
    final tileSize = (boardWidth / GameConstants.boardSize) - 6;

    return Center(
      child: Container(
        width: boardWidth + 16,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(GameConstants.boardSize, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(GameConstants.boardSize, (col) {
                final isSelected = selectedRow == row && selectedCol == col;
                return ItemTile(
                  item: board[row][col],
                  isSelected: isSelected,
                  size: tileSize,
                  onTap: () => onTileTap(row, col),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
