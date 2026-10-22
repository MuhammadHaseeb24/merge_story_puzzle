import 'dart:math';

import 'package:flutter/material.dart';

enum ItemType {
  seed,
  sprout,
  flower,
  bouquet,
  bench,
  fountain,
  greenhouse,
  statue,
}

extension ItemTypeInfo on ItemType {
  String get displayName => switch (this) {
        ItemType.seed => 'Seed',
        ItemType.sprout => 'Sprout',
        ItemType.flower => 'Flower',
        ItemType.bouquet => 'Bouquet',
        ItemType.bench => 'Garden Bench',
        ItemType.fountain => 'Fountain',
        ItemType.greenhouse => 'Greenhouse',
        ItemType.statue => 'Statue',
      };

  String get emoji => switch (this) {
        ItemType.seed => '🌱',
        ItemType.sprout => '🌿',
        ItemType.flower => '🌸',
        ItemType.bouquet => '💐',
        ItemType.bench => '🪑',
        ItemType.fountain => '⛲',
        ItemType.greenhouse => '🏡',
        ItemType.statue => '🗿',
      };

  Color get color => switch (this) {
        ItemType.seed => const Color(0xFFA5D6A7),
        ItemType.sprout => const Color(0xFF81C784),
        ItemType.flower => const Color(0xFFF8BBD9),
        ItemType.bouquet => const Color(0xFFF48FB1),
        ItemType.bench => const Color(0xFFBCAAA4),
        ItemType.fountain => const Color(0xFF80DEEA),
        ItemType.greenhouse => const Color(0xFF80CBC4),
        ItemType.statue => const Color(0xFFB0BEC5),
      };

  /// The tier this type merges into, or null at the top tier.
  ItemType? get next =>
      index + 1 < ItemType.values.length ? ItemType.values[index + 1] : null;
}

class MergeItem {
  MergeItem({
    required this.type,
    this.level = 1,
    String? id,
  }) : id = id ?? _generateId();

  final ItemType type;

  /// Always 1 for the first seven types. For [ItemType.statue] it counts up
  /// forever: two statues of the same level merge into level + 1.
  final int level;
  final String id;

  static final Random _idRandom = Random();
  static int _counter = 0;

  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_counter++}-${_idRandom.nextInt(1 << 20)}';

  static const List<({String name, String emoji, Color color})> _legend = [
    (name: 'Statue', emoji: '🗿', color: Color(0xFFB0BEC5)),
    (name: 'Golden Crown', emoji: '👑', color: Color(0xFFFFD54F)),
    (name: 'Crystal', emoji: '💎', color: Color(0xFF81D4FA)),
    (name: 'Starlight', emoji: '🌟', color: Color(0xFFFFF176)),
    (name: 'Rainbow', emoji: '🌈', color: Color(0xFFCE93D8)),
    (name: 'Oracle Orb', emoji: '🔮', color: Color(0xFFB39DDB)),
    (name: 'Little Planet', emoji: '🪐', color: Color(0xFFFFAB91)),
    (name: 'Comet', emoji: '☄️', color: Color(0xFF90CAF9)),
  ];

  bool get _legendary => type == ItemType.statue;
  int get _legendIndex => level < 1 ? 0 : level - 1;

  String get displayName {
    if (!_legendary) return type.displayName;
    final l = _legend[_legendIndex % _legend.length];
    final cycle = _legendIndex ~/ _legend.length;
    return cycle == 0 ? l.name : '${l.name} ${cycle + 1}';
  }

  String get emoji =>
      _legendary ? _legend[_legendIndex % _legend.length].emoji : type.emoji;

  Color get color =>
      _legendary ? _legend[_legendIndex % _legend.length].color : type.color;

  /// Overall tier (0 = seed). Grows without limit.
  int get tierNumber => type.index + _legendIndex;

  /// The item this merges into. There is no top tier: statues keep evolving.
  MergeItem get nextTier {
    final nextType = type.next;
    return nextType == null
        ? MergeItem(type: type, level: level + 1)
        : MergeItem(type: nextType);
  }

  bool canMergeWith(MergeItem other) =>
      type == other.type && level == other.level;

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'level': level,
        'id': id,
      };

  factory MergeItem.fromJson(Map<String, dynamic> json) {
    final typeIndex = json['type'] as int;
    if (typeIndex < 0 || typeIndex >= ItemType.values.length) {
      throw FormatException('Unknown item type index: $typeIndex');
    }
    return MergeItem(
      type: ItemType.values[typeIndex],
      level: json['level'] as int? ?? 1,
      id: json['id'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MergeItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
