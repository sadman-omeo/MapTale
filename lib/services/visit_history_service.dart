import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VisitHistoryService {
  static const String _key = 'visit_history';

  static Future<void> saveVisit({
    required String landmarkTitle,
    required String visitedAt,
    required dynamic distance,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final oldList = prefs.getStringList(_key) ?? [];

    final newVisit = jsonEncode({
      'landmarkTitle': landmarkTitle,
      'visitedAt': visitedAt,
      'distance': distance,
    });

    oldList.insert(0, newVisit);

    await prefs.setStringList(_key, oldList);
  }

  static Future<List<Map<String, dynamic>>> getVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final storedList = prefs.getStringList(_key) ?? [];

    return storedList
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  static Future<void> clearVisits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}