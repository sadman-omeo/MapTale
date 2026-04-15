import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/landmarks_model.dart';


class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/exm3/api.php';
  static const String studentKey = '22201333';
  static Future<List<Landmarks>> getLandmarks() async {
    final uri = Uri.parse('$baseUrl?action=get_landmarks&key=$studentKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);


      if (decoded is List) {
        return decoded.map((item) => Landmarks.fromJson(item)).toList();
      }

      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => Landmarks.fromJson(item)).toList();
      }

      throw Exception('Unexpected API response format');
    }
    else {
      throw Exception('Failed to load Landmarks!');
    }
  }
}