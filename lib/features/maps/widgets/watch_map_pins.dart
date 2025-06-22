import 'package:cochasqui_park/features/maps/widgets/map_pin.dart';
import 'package:latlong2/latlong.dart';
import 'package:powersync/powersync.dart';

Stream<List<MapPin>> watchMapPins(PowerSyncDatabase db, String? userId) {
  final String sqlQuery;
  final List<Object?> parameters;

  if (userId != null) {
    sqlQuery = '''
      SELECT
        mp.id,
        mp.latitude,
        mp.longitude,
        mp.title,
        mp.description,
        mp.type,
        (vp.pin_id IS NOT NULL) AS visited -- Boolean PowerSync lo maneja como 0 o 1
      FROM map_pins mp
      LEFT JOIN visited_pins vp
        ON mp.id = vp.pin_id AND vp.user_id = ?
    ''';
    parameters = [userId];
  } else {
    sqlQuery = '''
      SELECT
        id,
        latitude,
        longitude,
        title,
        description,
        type,
        FALSE AS visited -- Siempre FALSE para usuarios no logueados
      FROM map_pins
    ''';
    parameters = []; 
  }

  return db.watch(
    sqlQuery,
    parameters: parameters,
  ).map((rows) {
    return rows.map((row) {
      if (row['id'] == null || row['latitude'] == null || row['longitude'] == null ||
          row['title'] == null || row['description'] == null || row['type'] == null) {
        return null;
      }

      try {
        final int id = int.parse(row['id'].toString()); 
        final double latitude = row['latitude'] as double;
        final double longitude = row['longitude'] as double;
        final String title = row['title'] as String;
        final String description = row['description'] as String; 
        final String type = row['type'] as String;             
        final bool visited = (row['visited'] == 1); 

        return MapPin(
          id: id,
          location: LatLng(latitude, longitude),
          title: title,
          description: description,
          type: type,
          visited: visited,
        );
      } catch (e) {
        return null; 
      }
    }).whereType<MapPin>().toList(); 
  });
}