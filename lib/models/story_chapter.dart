class StoryChapter {
  final int id;
  final String title;
  final String content;
  final String characterName;
  final String characterEmoji;
  final int requiredMerges; // unlocks after this many total merges
  final int level;           // visual level number shown to player
  final bool isUnlocked;

  const StoryChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.characterName,
    required this.characterEmoji,
    required this.requiredMerges,
    required this.level,
    this.isUnlocked = false,
  });

  StoryChapter copyWith({bool? isUnlocked}) {
    return StoryChapter(
      id: id,
      title: title,
      content: content,
      characterName: characterName,
      characterEmoji: characterEmoji,
      requiredMerges: requiredMerges,
      level: level,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
      };

  /// 30 rich story chapters. Players easily reach 100+ merges / levels through normal play.
  static List<StoryChapter> getInitialChapters() {
    return [
      // ===== PROLOGUE =====
      const StoryChapter(
        id: 1,
        level: 1,
        title: 'The Abandoned Gate',
        content:
            'You push open the creaky iron gate of Whispering Gardens. Weeds have claimed almost everything, but something about this place feels… alive.\n\nA soft voice seems to whisper on the wind.\n\n"Welcome back," it says. But you\'ve never been here before.',
        characterName: 'Narrator',
        characterEmoji: '📖',
        requiredMerges: 0,
        isUnlocked: true,
      ),
      const StoryChapter(
        id: 2,
        level: 2,
        title: 'First Sprouts',
        content:
            'As the first green shoots break through the soil, a young woman appears among the roses. Her name is Lila.\n\n"You\'re actually restoring it?" she asks, eyes wide. "My grandmother used to tend these gardens. I thought no one would ever care again."',
        characterName: 'Lila',
        characterEmoji: '👩‍🌾',
        requiredMerges: 5,
      ),
      const StoryChapter(
        id: 3,
        level: 3,
        title: 'The Old Letter',
        content:
            'While clearing a path, you find a weathered letter tucked under a stone bench. It is addressed to "My dearest Eleanor."\n\nLila goes quiet when she sees the handwriting. "That\'s my grandfather\'s writing… They never told me the full story."',
        characterName: 'Lila',
        characterEmoji: '💌',
        requiredMerges: 12,
      ),
      const StoryChapter(
        id: 4,
        level: 4,
        title: 'Midnight Fountain',
        content:
            'One evening the fountain begins to flow again. Under the moonlight, Lila sits beside you.\n\n"Grandmother said the gardens only bloomed for people who truly loved them. I think… she was waiting for someone like you."',
        characterName: 'Lila',
        characterEmoji: '🌕',
        requiredMerges: 20,
      ),
      const StoryChapter(
        id: 5,
        level: 5,
        title: 'The Hidden Greenhouse',
        content:
            'Behind the overgrown ivy you discover a glass greenhouse still intact. Inside are journals, dried flowers, and a single photograph of a young couple smiling among the same roses.\n\nLila whispers, "They never stopped loving each other. Even after everything."',
        characterName: 'Lila',
        characterEmoji: '🏡',
        requiredMerges: 30,
      ),

      // ===== ACT 2 =====
      const StoryChapter(
        id: 6,
        level: 6,
        title: 'Memories in the Soil',
        content:
            'Every time you merge a new flower, Lila remembers another story. "This bench is where they had their first argument… and their first apology," she laughs softly.\n\nThe gardens are teaching both of you.',
        characterName: 'Lila',
        characterEmoji: '🌱',
        requiredMerges: 40,
      ),
      const StoryChapter(
        id: 7,
        level: 7,
        title: 'A Visitor',
        content:
            'An older man appears at the gate. He introduces himself as Mr. Elias, the last gardener who worked here decades ago.\n\n"I never thought I\'d see these paths clear again," he says, eyes shining.',
        characterName: 'Elias',
        characterEmoji: '👴',
        requiredMerges: 50,
      ),
      const StoryChapter(
        id: 8,
        level: 8,
        title: 'The Promise',
        content:
            'Elias tells you about the promise Eleanor and Thomas made: "As long as the gardens live, so does our love."\n\nLila squeezes your hand. "Maybe that\'s why the wind still whispers their names."',
        characterName: 'Elias',
        characterEmoji: '🤝',
        requiredMerges: 60,
      ),
      const StoryChapter(
        id: 9,
        level: 9,
        title: 'Rainy Afternoon',
        content:
            'A sudden rain forces you both into the greenhouse. While waiting, Lila opens one of the old journals.\n\n"They wrote to each other every day they were apart. I want a love like that someday." She looks at you for a long second.',
        characterName: 'Lila',
        characterEmoji: '🌧️',
        requiredMerges: 75,
      ),
      const StoryChapter(
        id: 10,
        level: 10,
        title: 'The First Bloom Festival',
        content:
            'With the main paths restored, the village decides to hold a small festival. Lanterns hang from the trees. Children run between the flower beds.\n\nLila dances under the lights. For the first time the gardens feel truly alive again.',
        characterName: 'Villagers',
        characterEmoji: '🎉',
        requiredMerges: 90,
      ),

      // ===== ACT 3 =====
      const StoryChapter(
        id: 11,
        level: 12,
        title: 'Secrets in the Roots',
        content:
            'While digging near the old oak, you uncover a small metal box. Inside is a lock of hair, a dried rose, and a note: "If you are reading this, the gardens have chosen a new guardian."\n\nLila\'s eyes fill with tears.',
        characterName: 'Lila',
        characterEmoji: '🗝️',
        requiredMerges: 110,
      ),
      const StoryChapter(
        id: 12,
        level: 14,
        title: 'Elias\'s Confession',
        content:
            'Elias finally tells the full truth. He was in love with Eleanor too, but stepped aside so she could be happy with Thomas.\n\n"I stayed to protect their dream. Now I can finally rest."',
        characterName: 'Elias',
        characterEmoji: '💔',
        requiredMerges: 130,
      ),
      const StoryChapter(
        id: 13,
        level: 16,
        title: 'Under the Stars',
        content:
            'You and Lila sit on the highest hill overlooking the fully blooming gardens. The stars are bright.\n\n"I used to think this place was only about the past," she says. "Now I think it\'s about the future too."',
        characterName: 'Lila',
        characterEmoji: '✨',
        requiredMerges: 150,
      ),
      const StoryChapter(
        id: 14,
        level: 18,
        title: 'The Letter You Write',
        content:
            'Inspired by the old journals, you write a letter of your own and place it in the greenhouse. Lila finds it the next morning.\n\nShe doesn\'t say anything — she just hugs you tightly for a long time.',
        characterName: 'You & Lila',
        characterEmoji: '📝',
        requiredMerges: 170,
      ),
      const StoryChapter(
        id: 15,
        level: 20,
        title: 'A New Tradition',
        content:
            'Every full moon, the village now gathers in the gardens. They call it the Night of Whispers. Stories are shared, flowers are gifted, and quiet hopes are spoken into the wind.',
        characterName: 'Narrator',
        characterEmoji: '🌙',
        requiredMerges: 190,
      ),

      // ===== FINAL ARC =====
      const StoryChapter(
        id: 16,
        level: 25,
        title: 'The Last Journal',
        content:
            'In the deepest drawer of the greenhouse desk, you find Eleanor\'s final entry:\n\n"Whoever tends these gardens after us… know that love never truly leaves a place. It only waits to be remembered."',
        characterName: 'Eleanor',
        characterEmoji: '📔',
        requiredMerges: 220,
      ),
      const StoryChapter(
        id: 17,
        level: 30,
        title: 'Lila\'s Choice',
        content:
            'Lila has been offered a job in the city. She stands at the gate, suitcase in hand, looking back at the gardens… and at you.\n\n"I thought I needed to leave to find my life. But maybe my life was always waiting here."',
        characterName: 'Lila',
        characterEmoji: '🧳',
        requiredMerges: 250,
      ),
      const StoryChapter(
        id: 18,
        level: 35,
        title: 'Homecoming',
        content:
            'She stays. The two of you plant a new rose bush together — one that has never existed in these gardens before.\n\n"Our story starts here," she says.',
        characterName: 'Lila',
        characterEmoji: '🌹',
        requiredMerges: 280,
      ),
      const StoryChapter(
        id: 19,
        level: 40,
        title: 'Seasons Pass',
        content:
            'Spring turns to summer, summer to autumn. The gardens change, but the feeling stays the same. Children who once ran through the paths now bring their own children.\n\nYou have become part of the story.',
        characterName: 'Narrator',
        characterEmoji: '🍂',
        requiredMerges: 320,
      ),
      const StoryChapter(
        id: 20,
        level: 50,
        title: 'Forever Whispering',
        content:
            'Years later, someone new will open the gate and hear the same soft voice on the wind.\n\nBut for now, under the blooming roses, with Lila\'s hand in yours, the gardens are perfectly quiet… and perfectly full of life.\n\nThe end is only another beginning.',
        characterName: 'Narrator',
        characterEmoji: '💕',
        requiredMerges: 400,
      ),

      // Extra chapters for depth
      const StoryChapter(
        id: 21,
        level: 8,
        title: 'Morning Coffee',
        content:
            'Lila brings two cups of coffee to the bench every morning now. You sit in comfortable silence, watching the mist rise from the fountain.\n\nSome of the best conversations need no words.',
        characterName: 'Lila',
        characterEmoji: '☕',
        requiredMerges: 65,
      ),
      const StoryChapter(
        id: 22,
        level: 11,
        title: 'The Lost Key',
        content:
            'You find an old brass key while merging near the statue. It opens a small shed filled with gardening tools that still shine as if used yesterday.',
        characterName: 'Narrator',
        characterEmoji: '🔑',
        requiredMerges: 100,
      ),
      const StoryChapter(
        id: 23,
        level: 15,
        title: 'Children\'s Laughter',
        content:
            'A group of local children start coming every afternoon. They help water the flowers and invent stories about the "Garden Guardians".\n\nYou and Lila have become legends in their eyes.',
        characterName: 'Children',
        characterEmoji: '🧒',
        requiredMerges: 140,
      ),
      const StoryChapter(
        id: 24,
        level: 22,
        title: 'A Stormy Night',
        content:
            'A strong storm hits. You both rush to protect the young plants. When it\'s over, soaked and laughing, Lila says, "I\'ve never felt more at home than right now."',
        characterName: 'Lila',
        characterEmoji: '⛈️',
        requiredMerges: 200,
      ),
      const StoryChapter(
        id: 25,
        level: 28,
        title: 'The Portrait',
        content:
            'An artist from the next town paints a portrait of the restored gardens and gifts it to you. It now hangs in the greenhouse, watching over everything.',
        characterName: 'Artist',
        characterEmoji: '🖼️',
        requiredMerges: 240,
      ),
      const StoryChapter(
        id: 26,
        level: 33,
        title: 'Quiet Understanding',
        content:
            'You don\'t need to say "I love you" yet. The way Lila looks at the roses you planted together says enough for both of you.',
        characterName: 'Lila',
        characterEmoji: '🤫',
        requiredMerges: 270,
      ),
      const StoryChapter(
        id: 27,
        level: 38,
        title: 'Passing the Torch',
        content:
            'Elias visits one last time. He places his old gardening gloves in your hands.\n\n"These gardens chose well," he says, and walks away smiling.',
        characterName: 'Elias',
        characterEmoji: '🧤',
        requiredMerges: 300,
      ),
      const StoryChapter(
        id: 28,
        level: 45,
        title: 'The Anniversary',
        content:
            'One year to the day you first opened the gate, the entire village throws a surprise celebration. Lila stands on the fountain steps and tells everyone the real story — including the part about you.',
        characterName: 'Lila',
        characterEmoji: '🎊',
        requiredMerges: 350,
      ),
      const StoryChapter(
        id: 29,
        level: 55,
        title: 'New Seeds',
        content:
            'Together you order rare seeds from far away. The next generation of flowers will be ones Eleanor and Thomas never saw.\n\nThe story continues to grow.',
        characterName: 'You & Lila',
        characterEmoji: '🌍',
        requiredMerges: 450,
      ),
      const StoryChapter(
        id: 30,
        level: 60,
        title: 'Always',
        content:
            'On quiet evenings you still hear the gardens whisper. Sometimes it sounds like Eleanor. Sometimes like Thomas. Sometimes it just sounds like home.\n\nAnd that is more than enough.',
        characterName: 'Narrator',
        characterEmoji: '🏡',
        requiredMerges: 500,
      ),
    ];
  }
}
