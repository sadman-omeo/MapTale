import 'package:flutter/material.dart';
import '../models/landmarks_model.dart';
import '../services/api_service.dart';

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}


class _LandmarksScreenState extends State<LandmarksScreen> {
  late Future<List<Landmarks>> _landmarksFuture;

  @override
  void initState() {
    super.initState();
    _landmarksFuture = ApiService.getLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks'),
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
              return ListView.builder(
                itemCount: landmarks.length,
                itemBuilder: (context, index) {
                  final landmark = landmarks[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: landmark.image.isNotEmpty
                          ? Image.network(
                        landmark.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40);
                        },
                      )
                          : const Icon(Icons.image_not_supported, size: 40),
                      title: Text(landmark.title),
                      subtitle: Text('Score: ${landmark.score}'),
                      trailing: Text('ID: ${landmark.id}'),
                    ),
                  );
                },
              );
            },
        ),
    );
  }
}