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

class MergeItem {
  final ItemType type;
  final int level; // 1-based within type progression
  final String id;

  MergeItem({
    required this.type,
    required this.level,
    String? id,
  }) : id = id ?? UniqueKey().toString();

  String get displayName {
    switch (type) {
      case ItemType.seed:
        return 'Seed';
      case ItemType.sprout:
        return 'Sprout';
      case ItemType.flower:
        return 'Flower';
      case ItemType.bouquet:
        return 'Bouquet';
      case ItemType.bench:
        return 'Garden Bench';
      case ItemType.fountain:
        return 'Fountain';
      case ItemType.greenhouse:
        return 'Greenhouse';
      case ItemType.statue:
        return 'Statue';
    }
  }

  String get emoji {
    switch (type) {
      case ItemType.seed:
        return '🌱';
      case ItemType.sprout:
        return '🌿';
      case ItemType.flower:
        return '🌸';
      case ItemType.bouquet:
        return '💐';
      case ItemType.bench:
        return '🪑';
      case ItemType.fountain:
        return '⛲';
      case ItemType.greenhouse:
        return '🏡';
      case ItemType.statue:
        return '🗿';
    }
  }

  Color get color {
    switch (type) {
      case ItemType.seed:
        return const Color(0xFFA5D6A7);
      case ItemType.sprout:
        return const Color(0xFF81C784);
      case ItemType.flower:
        return const Color(0xFFF8BBD9);
      case ItemType.bouquet:
        return const Color(0xFFF48FB1);
      case ItemType.bench:
        return const Color(0xFFBCAAA4);
      case ItemType.fountain:
        return const Color(0xFF80DEEA);
      case ItemType.greenhouse:
        return const Color(0xFF80CBC4);
      case ItemType.statue:
        return const Color(0xFFB0BEC5);
    }
  }

  /// Returns the next tier item if this can be merged further.
  MergeItem? get nextTier {
    switch (type) {
      case ItemType.seed:
        return MergeItem(type: ItemType.sprout, level: 1);
      case ItemType.sprout:
        return MergeItem(type: ItemType.flower, level: 1);
      case ItemType.flower:
        return MergeItem(type: ItemType.bouquet, level: 1);
      case ItemType.bouquet:
        return MergeItem(type: ItemType.bench, level: 1);
      case ItemType.bench:
        return MergeItem(type: ItemType.fountain, level: 1);
      case ItemType.fountain:
        return MergeItem(type: ItemType.greenhouse, level: 1);
      case ItemType.greenhouse:
        return MergeItem(type: ItemType.statue, level: 1);
      case ItemType.statue:
        return null; // Max tier
    }
  }

  bool canMergeWith(MergeItem other) {
    return type == other.type && level == other.level;
  }

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'level': level,
        'id': id,
      };

  factory MergeItem.fromJson(Map<String, dynamic> json) {
    return MergeItem(
      type: ItemType.values[json['type'] as int],
      level: json['level'] as int,
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
