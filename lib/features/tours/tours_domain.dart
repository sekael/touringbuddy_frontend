import 'package:maplibre_gl/maplibre_gl.dart';

class Tour {
  final String id;
  final String userId;
  final DateTime? plannedDate;
  final LatLng goal;

  Tour({
    required this.id,
    required this.userId,
    this.plannedDate,
    required this.goal,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      userId: json['user_id'],
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'])
          : null,
      goal: parseGeography(json['goal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'planned_date': plannedDate?.toIso8601String().split('T')[0],
      'goal': {
        'type': 'Point',
        'coordinates': [goal.longitude, goal.latitude],
      },
    };
  }

  static LatLng parseGeography(dynamic goal) {
    if (goal is Map && goal.containsKey('coordinates')) {
      // Handle GeoJSON format
      final coords = goal['coordinates'] as List;
      return LatLng(coords[1] as double, coords[0] as double);
    } else if (goal is String) {
      // Handle WKT format "POINT(8.2 46.8)"
      final values = goal
          .replaceAll('POINT(', '')
          .replaceAll(')', '')
          .split(' ');
      return LatLng(double.parse(values[1]), double.parse(values[0]));
    }
    throw Exception('Unknown geography format');
  }
}
