import 'dart:math' as math;

import '../utils/constants.dart';
import 'item.dart';
import 'story_chapter.dart';

class PlayerData {
  PlayerData({
    this.energy = GameConstants.maxEnergy,
    this.maxEnergy = GameConstants.maxEnergy,
    this.totalMerges = 0,
    this.coins = GameConstants.startingCoins,
    DateTime? lastEnergyUpdate,
    List<StoryChapter>? chapters,
    List<List<MergeItem?>>? board,
    this.hasCompletedTutorial = false,
    this.hapticsEnabled = true,
  })  : lastEnergyUpdate = lastEnergyUpdate ?? DateTime.now(),
        chapters = chapters ?? StoryChapter.getInitialChapters(),
        board = board ?? createEmptyBoard();

  int energy;
  int maxEnergy;
  int totalMerges;
  int coins;
  DateTime lastEnergyUpdate;
  List<StoryChapter> chapters; // sorted by requiredMerges
  List<List<MergeItem?>> board; // boardSize x boardSize grid
  bool hasCompletedTutorial;
  bool hapticsEnabled;

  static List<List<MergeItem?>> createEmptyBoard() {
    return List.generate(
      GameConstants.boardSize,
      (_) => List<MergeItem?>.filled(GameConstants.boardSize, null),
    );
  }

  // ---------------------------------------------------------------- Energy

  static int get _regenIntervalSeconds =>
      GameConstants.energyRegenMinutes * 60;

  /// Adds any energy earned since the last update, keeping leftover time so
  /// partial progress is never lost.
  void regenerateEnergy([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (energy >= maxEnergy) {
      lastEnergyUpdate = current;
      return;
    }
    final elapsed = current.difference(lastEnergyUpdate).inSeconds;
    if (elapsed < 0) {
      lastEnergyUpdate = current; // device clock moved backwards
      return;
    }
    final gained = elapsed ~/ _regenIntervalSeconds;
    if (gained <= 0) return;

    energy = math.min(maxEnergy, energy + gained);
    lastEnergyUpdate = energy >= maxEnergy
        ? current
        : lastEnergyUpdate.add(Duration(seconds: gained * _regenIntervalSeconds));
  }

  bool spendEnergy(int amount) {
    regenerateEnergy();
    if (energy < amount) return false;
    if (energy >= maxEnergy) lastEnergyUpdate = DateTime.now();
    energy -= amount;
    return true;
  }

  void addEnergy(int amount) {
    energy = math.min(energy + amount, maxEnergy + GameConstants.energyOvercap);
  }

  /// Time until the next point of energy, or null when already full.
  Duration? get timeToNextEnergy {
    if (energy >= maxEnergy) return null;
    final elapsed = DateTime.now().difference(lastEnergyUpdate).inSeconds;
    final remaining = _regenIntervalSeconds - (math.max(0, elapsed) % _regenIntervalSeconds);
    return Duration(seconds: remaining);
  }

  // ---------------------------------------------------------------- Story

  /// Unlocks every chapter whose requirement is met and returns the ones that
  /// were newly unlocked by this call.
  List<StoryChapter> unlockChapters() {
    final newlyUnlocked = <StoryChapter>[];
    for (var i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      if (!chapter.isUnlocked && totalMerges >= chapter.requiredMerges) {
        chapters[i] = chapter.copyWith(isUnlocked: true);
        newlyUnlocked.add(chapters[i]);
      }
    }
    return newlyUnlocked;
  }

  int get unlockedChapterCount => chapters.where((c) => c.isUnlocked).length;

  StoryChapter? get nextLockedChapter {
    for (final chapter in chapters) {
      if (!chapter.isUnlocked) return chapter;
    }
    return null;
  }

  // ---------------------------------------------------------------- Level

  /// merges needed -> level reached.
  static const List<List<int>> _levelTable = [
    [0, 1],
    [5, 2],
    [12, 3],
    [20, 4],
    [30, 5],
    [40, 6],
    [50, 7],
    [65, 8],
    [80, 10],
    [100, 14],
    [130, 18],
    [160, 22],
    [200, 28],
    [250, 35],
    [300, 42],
    [350, 50],
    [400, 55],
    [450, 60],
  ];

  /// Player level derived from total merges. Endless: +1 per 20 merges after 500.
  int get currentLevel {
    if (totalMerges >= 500) {
      return 60 + (totalMerges - 500) ~/ 20;
    }
    var level = 1;
    for (final row in _levelTable) {
      if (totalMerges >= row[0]) level = row[1];
    }
    return level;
  }

  /// 0..1 progress towards the next level.
  double get levelProgress {
    final t = totalMerges;
    if (t >= 500) return ((t - 500) % 20) / 20;
    var start = 0;
    var end = 500;
    for (var i = 0; i < _levelTable.length; i++) {
      if (t >= _levelTable[i][0]) {
        start = _levelTable[i][0];
        end = i + 1 < _levelTable.length ? _levelTable[i + 1][0] : 500;
      }
    }
    return ((t - start) / (end - start)).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------- Persistence

  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'maxEnergy': maxEnergy,
      'totalMerges': totalMerges,
      'coins': coins,
      'lastEnergyUpdate': lastEnergyUpdate.toIso8601String(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'board': board
          .map((row) => row.map((item) => item?.toJson()).toList())
          .toList(),
      'hasCompletedTutorial': hasCompletedTutorial,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List<dynamic>? ?? const [];
    final unlockedIds = <dynamic>{
      for (final c in chaptersJson)
        if (c is Map && c['isUnlocked'] == true) c['id'],
    };
    final chapters = StoryChapter.getInitialChapters()
        .map((ch) =>
            ch.copyWith(isUnlocked: ch.isUnlocked || unlockedIds.contains(ch.id)))
        .toList();

    final player = PlayerData(
      energy: json['energy'] as int? ?? GameConstants.maxEnergy,
      maxEnergy: json['maxEnergy'] as int? ?? GameConstants.maxEnergy,
      totalMerges: json['totalMerges'] as int? ?? 0,
      coins: json['coins'] as int? ?? GameConstants.startingCoins,
      lastEnergyUpdate: json['lastEnergyUpdate'] != null
          ? DateTime.parse(json['lastEnergyUpdate'] as String)
          : DateTime.now(),
      chapters: chapters,
      board: _parseBoard(json['board']),
      hasCompletedTutorial: json['hasCompletedTutorial'] as bool? ?? false,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
    player.unlockChapters();
    return player;
  }

  static List<List<MergeItem?>> _parseBoard(dynamic raw) {
    const size = GameConstants.boardSize;
    if (raw is! List || raw.length != size) return createEmptyBoard();

    final rows = <List<MergeItem?>>[];
    for (final row in raw) {
      if (row is! List || row.length != size) return createEmptyBoard();
      rows.add(
        row
            .map<MergeItem?>((cell) => cell == null
                ? null
                : MergeItem.fromJson(Map<String, dynamic>.from(cell as Map)))
            .toList(),
      );
    }
    return rows;
  }
}
