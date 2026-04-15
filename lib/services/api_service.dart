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

  static Future<Map<String, dynamic>> visitLandmark({
    required int landmarkId,
    required double userLati,
    required double userLongi,
  }) async {
    final uri = Uri.parse('$baseUrl?action=visit_landmark&key=$studentKey');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'landmark_id': landmarkId,
        'user_lat': userLati,
        'user_lon': userLongi,
      }),
    );

    final decoded =
    response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': true,
        'message': 'Visit successful',
        'raw': decoded,
      };
    }

    if (decoded is Map<String, dynamic>) {
      throw Exception(decoded['message']?.toString() ?? 'Visit failed');
    }

    throw Exception('Visit failed with status ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required String imagePath,
  }) async {
    final uri = Uri.parse('$baseUrl?action=create_landmark&key=$studentKey');

    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['lat'] = lat.toString()
      ..fields['lon'] = lon.toString()
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final decoded =
    response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': true,
        'message': 'Landmark created successfully',
        'raw': decoded,
      };
    }

    if (decoded is Map<String, dynamic>) {
      throw Exception(
        decoded['message']?.toString() ?? 'Create landmark failed',
      );
    }

    throw Exception('Create landmark failed with status ${response.statusCode}');
  }

}