import 'package:maplibre_gl/maplibre_gl.dart';

class Tour {
  final String id;
  final String userId;
  final DateTime? plannedDate;
  final LatLng goal;
  final String? name;
  final List<String> partnerIds;

  Tour({
    required this.id,
    required this.userId,
    this.plannedDate,
    required this.goal,
    this.name,
    this.partnerIds = const [],
  });

  // TODO: update view to support partner IDs
  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      userId: json['user_id'],
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'])
          : null,
      goal: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lon'] as num).toDouble(),
      ),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'planned_date': plannedDate?.toIso8601String().split('T')[0],
      'goal': 'SRID=4326;POINT(${goal.longitude} ${goal.latitude})',
      'name': name,
    };
  }

  Map<String, dynamic> toGeoJsonFeature() {
    return {
      'type': 'Feature',
      'id': id,
      'properties': {
        'name': name ?? '',
        'planned_date': plannedDate?.toIso8601String() ?? '',
      },
      'geometry': {
        'type': 'Point',
        'coordinates': [goal.longitude, goal.latitude],
      },
    };
  }
}
