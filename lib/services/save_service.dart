import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_data.dart';

class SaveService {
  static const _key = 'player_data_v1';

  static Future<void> save(PlayerData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<PlayerData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return PlayerData(); // fresh start
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerData.fromJson(map);
    } catch (e) {
      return PlayerData();
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
