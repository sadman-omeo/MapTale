import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/landmarks_model.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  late Future<List<Landmarks>> _landmarksFuture;

  @override
  void initState() {
    super.initState();
    _landmarksFuture = ApiService.getLandmarks();
  }

  Color _getMarkerColor(double score, double minScore, double maxScore) {
    if (minScore == maxScore) return Colors.blue;

    final normalize_score = (score - minScore) / (maxScore - minScore);

    if (normalize_score < 0.33) {
      return Colors.red;
    } else if (normalize_score < 0.66) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  void _showLandmarkDetails(Landmarks landmark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(landmark.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${landmark.id}'),
              Text('Score: ${landmark.score}'),
              Text('Latitude: ${landmark.lati}'),
              Text('Longitude: ${landmark.longi}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MAP'),
          centerTitle: true,
        ),
      body: FutureBuilder<List<Landmarks>>(
        future: _landmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final landmarks = snapshot.data ?? [];

          if (landmarks.isEmpty) {
            return const Center(
              child: Text('No landmarks found'),
            );
          }

          final scores = landmarks.map((e) => e.score).toList();
          final minScore = scores.reduce((a, b) => a < b ? a : b);
          final maxScore = scores.reduce((a, b) => a > b ? a : b);

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(23.6850, 90.3563),
              initialZoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.maptale',
              ),
              MarkerLayer(
                markers: landmarks.map((landmark) {
                  return Marker(
                    point: LatLng(landmark.lati, landmark.longi),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showLandmarkDetails(landmark),
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: _getMarkerColor(
                          landmark.score,
                          minScore,
                          maxScore,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}


