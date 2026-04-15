import 'package:flutter/material.dart';
import '../services/visit_history_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<List<Map<String, dynamic>>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  void _loadVisits() {
    _visitsFuture = VisitHistoryService.getVisits();
  }

  String _formatDate(String isoString) {
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await VisitHistoryService.clearVisits();
              setState(() {
                _loadVisits();
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _visitsFuture,
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

          final visits = snapshot.data ?? [];

          if (visits.isEmpty) {
            return const Center(
              child: Text('No visit history yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadVisits();
              });
            },
            child: ListView.builder(
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(visit['landmarkTitle']?.toString() ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visited at: ${_formatDate(visit['visitedAt']?.toString() ?? '')}',
                        ),
                        Text(
                          'Distance: ${visit['distance']?.toString() ?? 'Not returned'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}