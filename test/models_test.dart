import 'package:bloom_and_bonds/models/item.dart';
import 'package:bloom_and_bonds/models/player_data.dart';
import 'package:bloom_and_bonds/models/story_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MergeItem', () {
    test('progresses seed -> statue and then stops', () {
      var item = MergeItem(type: ItemType.seed);
      var steps = 0;
      while (item.nextTier != null) {
        item = item.nextTier!;
        steps++;
      }
      expect(item.type, ItemType.statue);
      expect(steps, ItemType.values.length - 1);
      expect(item.isMaxTier, isTrue);
    });

    test('only identical type and level can merge', () {
      final a = MergeItem(type: ItemType.seed);
      final b = MergeItem(type: ItemType.seed);
      final c = MergeItem(type: ItemType.sprout);
      expect(a.canMergeWith(b), isTrue);
      expect(a.canMergeWith(c), isFalse);
    });

    test('JSON round trip keeps type, level and id', () {
      final item = MergeItem(type: ItemType.fountain);
      final copy = MergeItem.fromJson(item.toJson());
      expect(copy, item);
      expect(copy.type, ItemType.fountain);
    });
  });

  group('PlayerData', () {
    test('regenerates 1 energy per 2 minutes and keeps leftover time', () {
      final now = DateTime(2026, 1, 1, 12);
      final player = PlayerData(
        energy: 10,
        lastEnergyUpdate: now.subtract(const Duration(minutes: 7)),
      );
      player.regenerateEnergy(now);
      expect(player.energy, 13);
      expect(now.difference(player.lastEnergyUpdate).inSeconds, 60);
    });

    test('cannot spend more energy than available', () {
      final player = PlayerData(energy: 0);
      expect(player.spendEnergy(1), isFalse);
      expect(player.energy, 0);
    });

    test('level grows with merges', () {
      expect(PlayerData(totalMerges: 0).currentLevel, 1);
      expect(PlayerData(totalMerges: 5).currentLevel, 2);
      expect(PlayerData(totalMerges: 500).currentLevel, 60);
      expect(PlayerData(totalMerges: 1300).currentLevel, 100);
    });

    test('chapters are sorted and unlock as merges grow', () {
      final chapters = StoryChapter.getInitialChapters();
      expect(chapters.length, 30);
      for (var i = 1; i < chapters.length; i++) {
        expect(chapters[i].requiredMerges,
            greaterThan(chapters[i - 1].requiredMerges));
      }

      final player = PlayerData(totalMerges: 5);
      final unlocked = player.unlockChapters();
      expect(unlocked.map((c) => c.requiredMerges), [5]);
      expect(player.unlockedChapterCount, 2);
      expect(player.unlockChapters(), isEmpty);
    });

    test('JSON round trip keeps board and unlocked chapters', () {
      final player = PlayerData(totalMerges: 12, coins: 250);
      player.unlockChapters();
      player.board[1][2] = MergeItem(type: ItemType.flower);

      final copy = PlayerData.fromJson(player.toJson());
      expect(copy.totalMerges, 12);
      expect(copy.coins, 250);
      expect(copy.board[1][2]?.type, ItemType.flower);
      expect(copy.unlockedChapterCount, player.unlockedChapterCount);
    });
  });
}
