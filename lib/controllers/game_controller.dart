import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/cell.dart';
import '../models/item.dart';
import '../models/player_data.dart';
import '../models/story_chapter.dart';
import '../services/save_service.dart';
import '../utils/constants.dart';

enum TapOutcome {
  ignored,
  selected,
  deselected,
  moved,
  swapped,
  merged,
  masterpiece,
}

enum SpawnOutcome { spawned, noEnergy, boardFull }

class TapResult {
  const TapResult(
    this.outcome, {
    this.item,
    this.coinsEarned = 0,
    this.newChapters = const <StoryChapter>[],
  });

  final TapOutcome outcome;
  final MergeItem? item;
  final int coinsEarned;
  final List<StoryChapter> newChapters;
}

/// Single source of truth for game state, shared by every screen.
class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({
    PlayerData? player,
    Random? random,
    bool autoTick = true,
  })  : player = player ?? PlayerData(),
        _loaded = player != null,
        _random = random ?? Random(),
        _autoTick = autoTick;

  PlayerData player;
  final Random _random;
  final bool _autoTick;

  bool _loaded;
  bool _initialized = false;
  Cell? _selected;
  Timer? _ticker;
  Timer? _saveTimer;

  /// Countdown to the next energy point (null when full). Updated every
  /// second without rebuilding the whole UI.
  final ValueNotifier<Duration?> nextEnergyIn = ValueNotifier<Duration?>(null);

  bool get loaded => _loaded;
  Cell? get selected => _selected;

  // ---------------------------------------------------------------- Lifecycle

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!_loaded) {
      player = await SaveService.load();
      _loaded = true;
    }
    player.regenerateEnergy();
    player.unlockChapters();
    WidgetsBinding.instance.addObserver(this);
    _startTicker();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tick();
    } else {
      unawaited(saveNow());
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    if (!_autoTick) return;
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final before = player.energy;
    player.regenerateEnergy();
    nextEnergyIn.value = player.timeToNextEnergy;
    if (player.energy != before) {
      notifyListeners();
      _scheduleSave();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _saveTimer?.cancel();
    nextEnergyIn.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- Saving

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(GameConstants.saveDebounce, () => SaveService.save(player));
  }

  Future<void> saveNow() {
    _saveTimer?.cancel();
    return SaveService.save(player);
  }

  // ---------------------------------------------------------------- Haptics

  Future<void> _haptic(Future<void> Function() feedback) async {
    if (!player.hapticsEnabled) return;
    try {
      await feedback();
    } catch (_) {
      // Haptics are best-effort (unsupported on some platforms).
    }
  }

  // ---------------------------------------------------------------- Board

  TapResult _select(int row, int col) {
    _selected = (row: row, col: col);
    unawaited(_haptic(HapticFeedback.selectionClick));
    notifyListeners();
    return const TapResult(TapOutcome.selected);
  }

  /// Handles a tap on a board cell: select, deselect, move or merge.
  TapResult onTileTap(int row, int col) {
    final board = player.board;
    final tapped = board[row][col];
    final sel = _selected;

    if (sel == null) {
      if (tapped == null) return const TapResult(TapOutcome.ignored);
      return _select(row, col);
    }

    if (sel.row == row && sel.col == col) {
      _selected = null;
      notifyListeners();
      return const TapResult(TapOutcome.deselected);
    }

    final source = board[sel.row][sel.col];
    if (source == null) {
      _selected = null;
      if (tapped == null) {
        notifyListeners();
        return const TapResult(TapOutcome.ignored);
      }
      return _select(row, col);
    }

    // Tap on an empty cell: move the selected item there.
    if (tapped == null) {
      board[row][col] = source;
      board[sel.row][sel.col] = null;
      _selected = null;
      unawaited(_haptic(HapticFeedback.lightImpact));
      notifyListeners();
      _scheduleSave();
      return TapResult(TapOutcome.moved, item: source);
    }

    final adjacent = (row - sel.row).abs() + (col - sel.col).abs() == 1;
    if (adjacent && source.canMergeWith(tapped)) {
      return _merge(from: sel, to: (row: row, col: col), source: source);
    }

    // Adjacent but different: swap places, so a full board is never a dead end.
    if (adjacent) {
      board[row][col] = source;
      board[sel.row][sel.col] = tapped;
      _selected = null;
      unawaited(_haptic(HapticFeedback.lightImpact));
      notifyListeners();
      _scheduleSave();
      return TapResult(TapOutcome.swapped, item: source);
    }

    return _select(row, col);
  }

  TapResult _merge({
    required Cell from,
    required Cell to,
    required MergeItem source,
  }) {
    final board = player.board;
    final next = source.nextTier;
    _selected = null;
    player.totalMerges++;

    final int coins;
    final TapOutcome outcome;
    if (next == null) {
      // Two top-tier items combine into a "masterpiece": both leave the board
      // so it never fills up permanently.
      board[from.row][from.col] = null;
      board[to.row][to.col] = null;
      coins = GameConstants.masterpieceBonus;
      outcome = TapOutcome.masterpiece;
    } else {
      board[to.row][to.col] = next;
      board[from.row][from.col] = null;
      coins = GameConstants.mergeCoinBase +
          next.type.index * GameConstants.mergeCoinPerTier;
      outcome = TapOutcome.merged;
    }
    player.coins += coins;

    final newChapters = player.unlockChapters();
    unawaited(_haptic(
      newChapters.isNotEmpty ? HapticFeedback.heavyImpact : HapticFeedback.mediumImpact,
    ));
    notifyListeners();
    _scheduleSave();

    return TapResult(
      outcome,
      item: next ?? source,
      coinsEarned: coins,
      newChapters: newChapters,
    );
  }

  SpawnOutcome spawn() {
    final empties = <Cell>[];
    for (var r = 0; r < GameConstants.boardSize; r++) {
      for (var c = 0; c < GameConstants.boardSize; c++) {
        if (player.board[r][c] == null) empties.add((row: r, col: c));
      }
    }
    if (empties.isEmpty) return SpawnOutcome.boardFull;
    if (!player.spendEnergy(GameConstants.energyCostSpawn)) {
      return SpawnOutcome.noEnergy;
    }

    final spot = empties[_random.nextInt(empties.length)];
    final roll = _random.nextDouble();
    final ItemType type;
    if (roll < GameConstants.seedChance) {
      type = ItemType.seed;
    } else if (roll < GameConstants.seedChance + GameConstants.sproutChance) {
      type = ItemType.sprout;
    } else {
      type = ItemType.flower;
    }

    player.board[spot.row][spot.col] = MergeItem(type: type);
    nextEnergyIn.value = player.timeToNextEnergy;
    unawaited(_haptic(HapticFeedback.selectionClick));
    notifyListeners();
    _scheduleSave();
    return SpawnOutcome.spawned;
  }

  // ---------------------------------------------------------------- Meta

  void claimFreeEnergy() {
    player.addEnergy(GameConstants.freeEnergyAmount);
    nextEnergyIn.value = player.timeToNextEnergy;
    notifyListeners();
    _scheduleSave();
  }

  void setHaptics(bool enabled) {
    player.hapticsEnabled = enabled;
    notifyListeners();
    _scheduleSave();
  }

  Future<void> completeTutorial() async {
    player.hasCompletedTutorial = true;
    notifyListeners();
    await saveNow();
  }

  Future<void> resetProgress() async {
    _saveTimer?.cancel();
    await SaveService.clear();
    player = PlayerData();
    _selected = null;
    nextEnergyIn.value = null;
    _tick();
    notifyListeners();
  }
}
