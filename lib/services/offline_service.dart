import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/landmarks_model.dart';

class OfflineService {
  static const String _cachedLandmarksKey = 'cached_landmarks';

  static Future<void> saveLandmarksCache(List<Landmarks> landmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = landmarks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_cachedLandmarksKey, data);
  }

  static Future<List<Landmarks>> loadLandmarksCache() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_cachedLandmarksKey) ?? [];

    return stored
        .map((item) => Landmarks.fromJson(jsonDecode(item)))
        .toList();
  }
}