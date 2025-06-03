import 'package:latlong2/latlong.dart';

class MapPin {
  final int id;
  final LatLng location;
  final String title;
  final String description;
  final String type;
  final bool visited; // nuevo

  MapPin({
    required this.id,
    required this.location,
    required this.title,
    required this.description,
    required this.type,
    this.visited = false,
  });

  factory MapPin.fromMap(Map<String, dynamic> map, {bool visited = false}) {
    return MapPin(
      id: map['id'],
      location: LatLng(map['lat'], map['lng']),
      title: map['title'],
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      visited: visited,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'lat': location.latitude,
      'lng': location.longitude,
    };
  }
}

