# Bloom & Bonds – Merge + Story Puzzle

A charming, fully responsive Flutter mobile game that combines classic **merge mechanics** with an ongoing **emotional story**.

Merge garden items on the board to restore the abandoned Whispering Gardens and unlock chapters of a light romance / mystery story.

## What’s New in this Version

- **First-time Tutorial / Guided Onboarding**  
  When the app is opened for the first time, a beautiful step-by-step tutorial teaches the player how to play (including an interactive live demo of merging).  
  At the end it clearly says “Dummy mode has ended – Now play for real!”

- **No Authentication** (as requested) – pure offline experience for v1. Auth can be added later.

- **30 Story Chapters** with rich narrative (players easily reach 100+ merges / high levels through normal play).

- **Level system** shown on home & game screen.

- **Fully Responsive** – looks good on small phones, large phones, and tablets.

## Features

- 5×5 merge board (tap → tap adjacent matching item)
- Item progression: Seed → Sprout → Flower → Bouquet → Bench → Fountain → Greenhouse → Statue
- Energy system (regenerates over time)
- 30 emotional story chapters
- Local save (SharedPreferences)
- Clean pastel UI + Google Fonts
- Tutorial with interactive practice merge

## How to Run

```bash
flutter pub get
flutter run
```

Works great on Android, iOS and Web.

## First Launch Flow

1. App opens → automatically shows Tutorial
2. Player learns the concept
3. Interactive step: actually merge two Seeds into a Sprout
4. Explains Energy + Story
5. “Dummy mode ended – Start Playing for Real!”
6. Goes to Home screen → player can now play freely

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── item.dart
│   ├── player_data.dart
│   └── story_chapter.dart
├── screens/
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── story_screen.dart
│   └── tutorial_screen.dart   ← NEW guided experience
├── widgets/
│   ├── board_widget.dart
│   ├── item_tile.dart
│   └── energy_bar.dart
├── services/
│   └── save_service.dart
└── utils/
    └── constants.dart
```

## Next Version Ideas

- Authentication (Google / Apple / Guest)
- Cloud save
- More item tiers & special events
- Drag & drop merging
- Season pass / daily rewards

Enjoy restoring the gardens!
