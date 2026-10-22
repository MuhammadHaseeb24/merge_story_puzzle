import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/story_chapter.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/app_card.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<GameController>().player;
    final chapters = player.chapters;
    final unlocked = player.unlockedChapterCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Story Chapters')),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlocked of ${chapters.length} chapters unlocked',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: unlocked / chapters.length,
                            minHeight: 8,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final chapter = chapters[index - 1];
              return _ChapterCard(
                chapter: chapter,
                number: index,
                totalMerges: player.totalMerges,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.number,
    required this.totalMerges,
  });

  final StoryChapter chapter;
  final int number;
  final int totalMerges;

  @override
  Widget build(BuildContext context) {
    final locked = !chapter.isUnlocked;
    final progress = chapter.requiredMerges == 0
        ? 1.0
        : math.min(1.0, totalMerges / chapter.requiredMerges);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: locked
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ChapterReader(chapter: chapter, number: number),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: locked
                      ? Colors.grey.shade300
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  locked ? '🔒' : chapter.characterEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter $number · ${chapter.title}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: locked ? Colors.grey : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locked
                          ? 'Level ${chapter.level} • $totalMerges / ${chapter.requiredMerges} merges'
                          : 'Level ${chapter.level} • ${chapter.characterName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (locked) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!locked)
                const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class ChapterReader extends StatelessWidget {
  const ChapterReader({super.key, required this.chapter, this.number});

  final StoryChapter chapter;
  final int? number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(title: Text(chapter.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ResponsiveCenter(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    chapter.characterEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    number == null
                        ? chapter.characterName
                        : 'Chapter $number · ${chapter.characterName}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  chapter.content,
                  style: GoogleFonts.lora(
                    fontSize: 17,
                    height: 1.65,
                    color: Colors.brown.shade900,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
