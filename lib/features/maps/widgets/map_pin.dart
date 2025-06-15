import 'package:latlong2/latlong.dart';

class MapPin {
  final int id;
  final LatLng location;
  final String title;
  final String description;
  final String type;
  final bool visited; 

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
      id: map['id'] as int, 
      location: LatLng(
        map['latitude'] as double, 
        map['longitude'] as double,
      ),
      title: map['title'] as String, 
      description: map['description'] as String? ?? '', 
      type: map['type'] as String? ?? '', 
      visited: visited,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
  }
}

