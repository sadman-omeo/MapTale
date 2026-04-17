

class Landmarks {
  final int id;
  final String title;
  final double lati;
  final double longi;
  final String image;
  final double score;
  final int visit_count;
  final double? avg_distance;

  Landmarks({
    required this.id,
    required this.title,
    required this.lati,
    required this.longi,
    required this.image,
    required this.score,
    required this.visit_count,
    required this.avg_distance,
  });

  factory Landmarks.fromJson(Map<String, dynamic> json) {
    return Landmarks(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      lati: double.tryParse(json['lat'].toString()) ?? 0.0,
      longi: double.tryParse(json['lon'].toString()) ?? 0.0,
      image: json['image']?.toString() ?? '',
      score: double.tryParse(json['score'].toString()) ?? 0.0,
      visit_count: int.tryParse(json['visit_count'].toString()) ?? 0,
      avg_distance: json['avg_distance'] == null
          ? null
          : double.tryParse(json['avg_distance'].toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lati,
      'lon': longi,
      'image': image,
      'score': score,
      'visit_count': visit_count,
      'avg_distance': avg_distance,
    };
  }
}