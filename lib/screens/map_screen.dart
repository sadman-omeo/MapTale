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

  Future<void> _refreshMap() async {
    setState(() {
      _landmarksFuture = ApiService.getLandmarks();
    });

    await _landmarksFuture;
  }

  Color _getMarkerColor(double score, double minScore, double maxScore) {
    if (minScore == maxScore) return Colors.blue;

    final normalizedScore = (score - minScore) / (maxScore - minScore);

    if (normalizedScore < 0.33) {
      return Colors.red;
    } else if (normalizedScore < 0.66) {
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
        actions: [
          IconButton(
            onPressed: () async {
              await _refreshMap();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No landmarks found'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _refreshMap();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
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