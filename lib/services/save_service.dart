import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_data.dart';

class SaveService {
  SaveService._();

  static const _key = 'player_data_v1';

  static Future<void> save(PlayerData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('SaveService.save failed: $e');
    }
  }

  static Future<PlayerData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return PlayerData(); // fresh start
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerData.fromJson(map);
    } catch (e) {
      debugPrint('SaveService.load failed, starting fresh: $e');
      return PlayerData();
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('SaveService.clear failed: $e');
    }
  }
}
