import 'dart:math';

import 'package:bloom_and_bonds/controllers/game_controller.dart';
import 'package:bloom_and_bonds/models/item.dart';
import 'package:bloom_and_bonds/models/player_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameController _controller({int energy = 30}) {
  final controller = GameController(
    player: PlayerData(energy: energy, hapticsEnabled: false),
    random: Random(1),
    autoTick: false,
  );
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('merging two adjacent seeds creates a sprout and rewards coins', () {
    final c = _controller();
    c.player.board[0][0] = MergeItem(type: ItemType.seed);
    c.player.board[0][1] = MergeItem(type: ItemType.seed);

    expect(c.onTileTap(0, 0).outcome, TapOutcome.selected);
    final result = c.onTileTap(0, 1);

    expect(result.outcome, TapOutcome.merged);
    expect(c.player.board[0][0], isNull);
    expect(c.player.board[0][1]?.type, ItemType.sprout);
    expect(c.player.totalMerges, 1);
    expect(c.player.coins, 100 + 5 + 1 * 2);
  });

  test('matching items that are not adjacent do not merge', () {
    final c = _controller();
    c.player.board[0][0] = MergeItem(type: ItemType.seed);
    c.player.board[0][3] = MergeItem(type: ItemType.seed);

    c.onTileTap(0, 0);
    expect(c.onTileTap(0, 3).outcome, TapOutcome.selected);
    expect(c.player.totalMerges, 0);
  });

  test('tapping an empty tile moves the selected item', () {
    final c = _controller();
    c.player.board[2][2] = MergeItem(type: ItemType.flower);

    c.onTileTap(2, 2);
    expect(c.onTileTap(4, 4).outcome, TapOutcome.moved);
    expect(c.player.board[2][2], isNull);
    expect(c.player.board[4][4]?.type, ItemType.flower);
  });

  test('adjacent different items swap places', () {
    final c = _controller();
    c.player.board[0][0] = MergeItem(type: ItemType.seed);
    c.player.board[0][1] = MergeItem(type: ItemType.flower);

    c.onTileTap(0, 0);
    expect(c.onTileTap(0, 1).outcome, TapOutcome.swapped);
    expect(c.player.board[0][0]?.type, ItemType.flower);
    expect(c.player.board[0][1]?.type, ItemType.seed);
  });

  test('two statues merge into a masterpiece and clear the board', () {
    final c = _controller();
    c.player.board[1][1] = MergeItem(type: ItemType.statue);
    c.player.board[1][2] = MergeItem(type: ItemType.statue);

    c.onTileTap(1, 1);
    final result = c.onTileTap(1, 2);

    expect(result.outcome, TapOutcome.masterpiece);
    expect(c.player.board[1][1], isNull);
    expect(c.player.board[1][2], isNull);
  });

  test('spawn costs energy and places an item', () {
    final c = _controller(energy: 5);
    expect(c.spawn(), SpawnOutcome.spawned);
    expect(c.player.energy, 4);
    final count = c.player.board.expand((r) => r).where((i) => i != null).length;
    expect(count, 1);
  });

  test('spawn fails without energy and when the board is full', () {
    final empty = _controller(energy: 0);
    expect(empty.spawn(), SpawnOutcome.noEnergy);

    final full = _controller(energy: 5);
    for (final row in full.player.board) {
      for (var i = 0; i < row.length; i++) {
        row[i] = MergeItem(type: ItemType.seed);
      }
    }
    expect(full.spawn(), SpawnOutcome.boardFull);
    expect(full.player.energy, 5); // nothing was charged
  });
}
