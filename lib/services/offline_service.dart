import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/landmarks_model.dart';

class OfflineService {
  static const String _cachedLandmarksKey = 'cached_landmarks';
  static const String _pendingVisitsKey = 'pending_visits';

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

  static Future<void> addPendingVisit({
    required int landmarkId,
    required String landmarkTitle,
    required double userLat,
    required double userLon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_pendingVisitsKey) ?? [];

    final pendingVisit = jsonEncode({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'landmarkId': landmarkId,
      'landmarkTitle': landmarkTitle,
      'userLat': userLat,
      'userLon': userLon,
      'createdAt': DateTime.now().toIso8601String(),
    });

    stored.add(pendingVisit);
    await prefs.setStringList(_pendingVisitsKey, stored);
  }

  static Future<List<Map<String, dynamic>>> getPendingVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_pendingVisitsKey) ?? [];

    return stored
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  static Future<void> removePendingVisit(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_pendingVisitsKey) ?? [];

    stored.removeWhere((item) {
      final decoded = Map<String, dynamic>.from(jsonDecode(item));
      return decoded['id']?.toString() == id;
    });

    await prefs.setStringList(_pendingVisitsKey, stored);
  }
}