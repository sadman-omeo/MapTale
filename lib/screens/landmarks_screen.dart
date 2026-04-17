import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmarks_model.dart';
import '../services/api_service.dart';
import '../services/visit_history_service.dart';
import '../services/offline_service.dart';

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends State<LandmarksScreen> {
  late Future<List<Landmarks>> _landmarksFuture;

  final TextEditingController _minScoreController = TextEditingController();

  bool _sortHighToLow = true;
  double? _minScore;

  @override
  void initState() {
    super.initState();
    _landmarksFuture = ApiService.getLandmarks();
    _syncPendingVisits();
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    return 'https://labs.anontech.info/cse489/exm3/$imagePath';
  }

  Future<void> _refreshLandmarks() async {
    await _syncPendingVisits();

    setState(() {
      _landmarksFuture = ApiService.getLandmarks();
    });

    await _landmarksFuture;
  }

  List<Landmarks> _processLandmarks(List<Landmarks> landmarks) {
    List<Landmarks> result = List.from(landmarks);

    if (_minScore != null) {
      result = result.where((item) => item.score >= _minScore!).toList();
    }

    result.sort((a, b) {
      if (_sortHighToLow) {
        return b.score.compareTo(a.score);
      } else {
        return a.score.compareTo(b.score);
      }
    });

    return result;
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

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is turned off');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _visitLandmark(Landmarks landmark) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final position = await _getCurrentLocation();

      try {
        final result = await ApiService.visitLandmark(
          landmarkId: landmark.id,
          userLati: position.latitude,
          userLongi: position.longitude,
        );

        final distance = result['distance'] ??
            result['avg_distance'] ??
            result['calculated_distance'];

        await VisitHistoryService.saveVisit(
          landmarkTitle: landmark.title,
          visitedAt: DateTime.now().toIso8601String(),
          distance: distance,
        );

        if (!mounted) return;
        Navigator.pop(context);

        final message =
            result['message']?.toString() ?? 'Visit request sent successfully';

        final finalText = distance != null
            ? '$message\nDistance: $distance'
            : message;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(finalText)),
        );
      } catch (e) {
        await OfflineService.addPendingVisit(
          landmarkId: landmark.id,
          landmarkTitle: landmark.title,
          userLat: position.latitude,
          userLon: position.longitude,
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet. Visit saved offline.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Visit Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _syncPendingVisits() async {
    final pendingVisits = await OfflineService.getPendingVisits();

    if (pendingVisits.isEmpty) return;

    int syncedCount = 0;

    for (final visit in pendingVisits) {
      try {
        final result = await ApiService.visitLandmark(
          landmarkId: int.tryParse(visit['landmarkId'].toString()) ?? 0,
          userLati: double.tryParse(visit['userLat'].toString()) ?? 0.0,
          userLongi: double.tryParse(visit['userLon'].toString()) ?? 0.0,
        );

        final distance = result['distance'] ??
            result['avg_distance'] ??
            result['calculated_distance'];

        await VisitHistoryService.saveVisit(
          landmarkTitle: visit['landmarkTitle']?.toString() ?? 'Unknown',
          visitedAt: visit['createdAt']?.toString() ??
              DateTime.now().toIso8601String(),
          distance: distance,
        );

        await OfflineService.removePendingVisit(
          visit['id']?.toString() ?? '',
        );

        syncedCount++;
      } catch (e) {
        // Keep failed syncs in pending storage
      }
    }

    if (!mounted) return;

    if (syncedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$syncedCount offline visit(s) synced successfully'),
        ),
      );
    }
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
        actions: [
          IconButton(
            onPressed: () async {
              await _refreshLandmarks();
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

          final allLandmarks = snapshot.data ?? [];
          final landmarks = _processLandmarks(allLandmarks);

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
                    ? RefreshIndicator(
                  onRefresh: _refreshLandmarks,
                  child: ListView(
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text('No landmarks found'),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _refreshLandmarks,
                  child: ListView.builder(
                    itemCount: landmarks.length,
                    itemBuilder: (context, index) {
                      final landmark = landmarks[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  landmark.image.isNotEmpty
                                      ? Image.network(
                                    _getImageUrl(landmark.image),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                        ) {
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          landmark.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                            'Score: ${landmark.score}'),
                                        Text('ID: ${landmark.id}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _visitLandmark(landmark),
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Visit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}