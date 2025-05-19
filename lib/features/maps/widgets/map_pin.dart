import 'package:latlong2/latlong.dart';

class MapPin {
  final LatLng location;
  final String title;
  final String description;
  final String type;

  MapPin({
    required this.location,
    required this.title,
    required this.description,
    required this.type,
  });

  factory MapPin.fromMap(Map<String, dynamic> map) {
    return MapPin(
      location: LatLng(map['lat'], map['lng']),
      title: map['title'],
      description: map['description'],
      type: map['type'],
    );
  }
}
