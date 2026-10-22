# Bloom & Bonds – Merge + Story Puzzle

A responsive Flutter game that combines **merge mechanics** with an emotional **story**.
Merge garden items to restore the abandoned Whispering Gardens and unlock 30 story chapters.

## Quick start

This archive contains the Dart source, tests and config. Generate the platform folders once, then run:

```bash
cd bloom_and_bonds
flutter create . --project-name bloom_and_bonds --platforms=android,ios,web
flutter pub get
flutter test
flutter run
```

Requires Flutter 3.27+ (Dart 3.6+).

> **Android release builds:** `google_fonts` downloads fonts at runtime, so add
> `<uses-permission android:name="android.permission.INTERNET"/>` to
> `android/app/src/main/AndroidManifest.xml`. To work fully offline, bundle the
> Poppins / Playfair Display / Lora fonts as assets instead.

## Gameplay

- 5×5 board. Tap an item, then tap an **adjacent matching item** to merge, an **empty tile** to move it, or a different **adjacent item** to swap places (so a full board is never a dead end).
- Tiers: Seed → Sprout → Flower → Bouquet → Bench → Fountain → Greenhouse → Statue.
- **Endless tiers:** after the Statue, matching items keep evolving (Golden Crown → Crystal → Starlight → Rainbow → …) forever.
- Merging is always free. Spawning costs 1 energy; energy regenerates over time, can be **claimed free without limit**, or bought with coins you win.
- **Endless levels:** +1 level every 20 merges after level 60.
- 30 story chapters unlock by total merges. Progress is saved locally (SharedPreferences).

## 3D look (v1.2)

- Tilted perspective board slab with sunken sockets and raised, extruded tiles that press down.
- Chunky `Button3D` buttons, extruded cards, floating/rotating 3D emoji and an animated glow background.
- Built with plain Flutter transforms (no extra packages), so it stays light and works on every platform.

## What changed in this version

**Responsive**
- Board, tiles and fonts size from available space (`LayoutBuilder`), not fixed pixels.
- Phone portrait, phone landscape, tablet and desktop/web layouts (board + side panel on wide screens).
- Content width capped on large screens; scrollable layouts so nothing overflows on short screens.
- System font scaling clamped (0.85–1.3×); all orientations allowed.

**Architecture**
- One `GameController` (Provider) shared by all screens – the old code created separate controllers per screen.
- Selection state moved out of the save model; startup routing via `AppGate` (splash → tutorial → home) instead of navigation hacks in `initState`.
- Central `AppTheme`, `Responsive` helpers and reusable widgets (`AppCard`, `StatChip`, `LevelProgressBar`, `SettingsSheet`).

**Bug fixes**
- Energy regeneration no longer discards partial minutes; countdown to next energy added.
- Chapter-unlock detection compares before/after instead of matching an exact merge count.
- Chapters are sorted by unlock order (chapters 21–30 were interleaved by id).
- The 30-second `Future.delayed` loop is replaced by a cancellable timer; saves are debounced and flushed when the app is backgrounded.
- Spawning on a full board no longer charges and refunds energy.
- Max-tier items could permanently fill the board; tiers are now endless and items can be swapped.
- Corrupt or malformed saves fall back safely; save/load errors are caught.
- Deprecated APIs replaced (`withOpacity` → `withValues`, `ColorScheme.background`).
- Removed the duplicate `constants_1.dart`.

**Polish**
- Tile pop animations, animated progress bars, haptics (toggle in Settings), chapter-unlocked bottom sheet.
- Story screen shows chapter numbers and progress toward locked chapters.
- Accessibility labels on board tiles and stats.
- Unit tests for item progression, energy, levels, chapters, save round-trip and merge logic.

## Project structure

```
lib/
├── main.dart
├── app.dart                     # MaterialApp + AppGate
├── controllers/game_controller.dart
├── models/ (cell, item, player_data, story_chapter)
├── screens/ (splash, home, game, story, tutorial)
├── widgets/ (board, item_tile, energy_bar, app_card, stat_chip,
│             level_progress_bar, settings_sheet)
├── services/save_service.dart
├── theme/app_theme.dart
└── utils/ (constants, responsive, ui_helpers)
test/ (models_test, game_controller_test)
```

## Ideas for next versions

Authentication, cloud save, drag-and-drop merging, daily rewards, sound effects, more tiers and events.
