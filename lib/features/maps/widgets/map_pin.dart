import 'package:latlong2/latlong.dart';

class MapPin {
  final LatLng location;
  final String title;
  final String description;
  final String type; // casa, museo, etc.

  MapPin({
    required this.location,
    required this.title,
    required this.description,
    required this.type,
  });
}
