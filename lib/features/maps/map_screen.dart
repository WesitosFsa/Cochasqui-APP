import 'dart:async';
import 'package:cochasqui_park/features/maps/map_controller.dart';
import 'package:cochasqui_park/features/maps/widgets/map_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  final Future<MbTiles> _futureMbtiles = _initMbtiles();
  MbTiles? _mbtiles;
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  static Future<MbTiles> _initMbtiles() async {
    final file = await copyAssetToFile('assets/maps/Cochasqui.mbtiles');
    return MbTiles(mbtilesPath: file.path);
  }

  @override
  void initState() {
    super.initState();
    _startListeningPosition();
  }
  

  Future<void> _startListeningPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // actualizar solo si se mueve 5 metros
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    _mbtiles?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }
  Widget getPinIcon(String type) {
  String asset;
  switch (type) {
    case 'entrada':
      asset = 'assets/images/pins/house_pin.png';
      break;
    case 'museo':
      asset = 'assets/images/pins/house_pin.png';
      break;
    case 'pirámide':
      asset = 'assets/images/pins/house_pin.png';
      break;
    default:
      asset = 'assets/images/pins/house_pin.png';
    }
    return Image.asset(asset, width: 40, height: 40);
  }
  void _showPinInfo(MapPin pin) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pin.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(pin.description),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    },
  );
}
final List<MapPin> _pins = [
  MapPin(
    location: LatLng(0.055, -78.305),
    title: 'Entrada Principal',
    description: 'Aquí empieza el recorrido.',
    type: 'entrada',
  ),
  MapPin(
    location: LatLng(0.056, -78.306),
    title: 'Museo',
    description: 'Contiene piezas arqueológicas importantes.',
    type: 'museo',
  ),
  MapPin(
    location: LatLng(0.054, -78.304),
    title: 'Pirámide 1',
    description: 'Una de las pirámides más antiguas.',
    type: 'pirámide',
  ),
];


  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Mapa del Parque Cochasqui'),
      ),
      body: FutureBuilder<MbTiles>(
        future: _futureMbtiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _mbtiles = snapshot.data;
            final metadata = _mbtiles!.getMetadata();

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    // Solo para desarrollo eliminar para produccion
                    'MBTiles Name: ${metadata.name}, Format: ${metadata.format}',
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      minZoom: 16,
                      maxZoom: 20,
                      initialZoom: 16,
                      initialCenter: const LatLng(0.054529, -78.305064),
                    ),
                    children: [
                      TileLayer(
                        tileProvider: MbTilesTileProvider(
                          mbtiles: _mbtiles!,
                          silenceTileNotFound: true,
                        ),
                      ),
                      MarkerLayer(
                      markers: _pins.map((pin) {
                        return Marker(
                          point: pin.location,
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _showPinInfo(pin),
                            child: getPinIcon(pin.type),
                          ),
                        );
                      }).toList(),
                    ),

                      if (_currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: _currentPosition!,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
}

