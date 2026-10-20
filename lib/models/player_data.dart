import 'item.dart';
import 'story_chapter.dart';

class PlayerData {
  int energy;
  int maxEnergy;
  int totalMerges;
  int coins;
  DateTime lastEnergyUpdate;
  List<StoryChapter> chapters;
  List<List<MergeItem?>> board; // 5x5 grid
  int selectedRow;
  int selectedCol;
  bool hasCompletedTutorial;

  PlayerData({
    this.energy = 30,
    this.maxEnergy = 30,
    this.totalMerges = 0,
    this.coins = 100,
    DateTime? lastEnergyUpdate,
    List<StoryChapter>? chapters,
    List<List<MergeItem?>>? board,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.hasCompletedTutorial = false,
  })  : lastEnergyUpdate = lastEnergyUpdate ?? DateTime.now(),
        chapters = chapters ?? StoryChapter.getInitialChapters(),
        board = board ?? _createEmptyBoard();

  static List<List<MergeItem?>> _createEmptyBoard() {
    return List.generate(5, (_) => List.generate(5, (_) => null));
  }

  void regenerateEnergy() {
    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyUpdate).inMinutes;
    if (minutesPassed > 0 && energy < maxEnergy) {
      // 1 energy every 2 minutes
      final energyGained = (minutesPassed / 2).floor();
      energy = (energy + energyGained).clamp(0, maxEnergy);
      lastEnergyUpdate = now;
    }
  }

  bool spendEnergy(int amount) {
    regenerateEnergy();
    if (energy >= amount) {
      energy -= amount;
      lastEnergyUpdate = DateTime.now();
      return true;
    }
    return false;
  }

  void addEnergy(int amount) {
    energy = (energy + amount).clamp(0, maxEnergy + 50); // allow slight overcap
  }

  void unlockChapters() {
    for (int i = 0; i < chapters.length; i++) {
      if (!chapters[i].isUnlocked && totalMerges >= chapters[i].requiredMerges) {
        chapters[i] = chapters[i].copyWith(isUnlocked: true);
      }
    }
  }

  int get unlockedChapterCount => chapters.where((c) => c.isUnlocked).length;

  /// Approximate current level based on merges (feels like 100+ levels over time)
  int get currentLevel {
    if (totalMerges < 5) return 1;
    if (totalMerges < 12) return 2;
    if (totalMerges < 20) return 3;
    if (totalMerges < 30) return 4;
    if (totalMerges < 40) return 5;
    if (totalMerges < 50) return 6;
    if (totalMerges < 65) return 7;
    if (totalMerges < 80) return 8;
    if (totalMerges < 100) return 10;
    if (totalMerges < 130) return 14;
    if (totalMerges < 160) return 18;
    if (totalMerges < 200) return 22;
    if (totalMerges < 250) return 28;
    if (totalMerges < 300) return 35;
    if (totalMerges < 350) return 42;
    if (totalMerges < 400) return 50;
    if (totalMerges < 450) return 55;
    return 60 + ((totalMerges - 500) ~/ 20).clamp(0, 40);
  }

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
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List<dynamic>? ?? [];
    final initialChapters = StoryChapter.getInitialChapters();
    final chapters = initialChapters.map((ch) {
      final saved = chaptersJson.cast<Map<String, dynamic>>().firstWhere(
            (c) => c['id'] == ch.id,
            orElse: () => {'id': ch.id, 'isUnlocked': ch.isUnlocked},
          );
      return ch.copyWith(isUnlocked: saved['isUnlocked'] as bool? ?? false);
    }).toList();

    List<List<MergeItem?>> board;
    if (json['board'] != null) {
      board = (json['board'] as List).map((row) {
        return (row as List).map((cell) {
          if (cell == null) return null;
          return MergeItem.fromJson(Map<String, dynamic>.from(cell));
        }).toList();
      }).toList();
    } else {
      board = PlayerData._createEmptyBoard();
    }

    return PlayerData(
      energy: json['energy'] as int? ?? 30,
      maxEnergy: json['maxEnergy'] as int? ?? 30,
      totalMerges: json['totalMerges'] as int? ?? 0,
      coins: json['coins'] as int? ?? 100,
      lastEnergyUpdate: json['lastEnergyUpdate'] != null
          ? DateTime.parse(json['lastEnergyUpdate'] as String)
          : DateTime.now(),
      chapters: chapters,
      board: board,
      hasCompletedTutorial: json['hasCompletedTutorial'] as bool? ?? false,
    );
  }
}
