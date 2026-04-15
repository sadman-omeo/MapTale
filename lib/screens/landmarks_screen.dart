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

  final TextEditingController _minScoreController = TextEditingController();

  List<Landmarks> _allLandmarks = [];
  bool _sortHighToLow = true;
  double? _minScore;

  @override
  void initState() {
    super.initState();
    _landmarksFuture = ApiService.getLandmarks();
  }

  List<Landmarks> _getProcessedLandmarks() {
    List<Landmarks> filtered = List.from(_allLandmarks);

    if (_minScore != null) {
      filtered = filtered.where((l) => l.score >= _minScore!).toList();
    }

    filtered.sort((a, b) {
      if (_sortHighToLow) {
        return b.score.compareTo(a.score);
      } else {
        return a.score.compareTo(b.score);
      }
    });

    return filtered;
  }

  void _applyFilter() {
    setState(() {
      final text = _minScoreController.text.trim();
      _minScore = text.isEmpty ? null : double.tryParse(text);
    });
  }

  void _clearFilter() {
    setState(() {
      _minScoreController.clear();
      _minScore = null;
    });
  }

  @override
  void dispose() {
    _minScoreController.dispose();
    super.dispose();
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          _allLandmarks = snapshot.data ?? [];
          final landmarks = _getProcessedLandmarks();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minScoreController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Minimum Score',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _applyFilter,
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _sortHighToLow = !_sortHighToLow;
                              });
                            },
                            child: Text(
                              _sortHighToLow
                                  ? 'Sort: High to Low'
                                  : 'Sort: Low to High',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _clearFilter,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: landmarks.isEmpty
                    ? const Center(child: Text('No landmarks found'))
                    : ListView.builder(
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
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 40,
                            );
                          },
                        )
                            : const Icon(
                          Icons.image_not_supported,
                          size: 40,
                        ),
                        title: Text(landmark.title),
                        subtitle: Text('Score: ${landmark.score}'),
                        trailing: Text('ID: ${landmark.id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}