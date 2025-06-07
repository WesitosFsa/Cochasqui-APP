import 'dart:async';
import 'package:cochasqui_park/features/admin/widgets/add_pin_form.dart';
import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cochasqui_park/features/maps/widgets/map_pin.dart';
import 'package:cochasqui_park/features/maps/map_controller.dart';

class ManageMapadmin extends StatefulWidget {
  const ManageMapadmin({super.key});

  @override
  State<ManageMapadmin> createState() => _ManageMapadmin();
}

class _ManageMapadmin extends State<ManageMapadmin> {
  final Future<MbTiles> _futureMbtiles = _initMbtiles();
  MbTiles? _mbtiles;
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  List<MapPin> _pins = [];

  static Future<MbTiles> _initMbtiles() async {
    final file = await copyAssetToFile('assets/maps/Cochasqui.mbtiles');
    return MbTiles(mbtilesPath: file.path);
  }

  @override
  void initState() {
    super.initState();
    _startListeningPosition();
    _loadPins();
  }
  void _editPin(MapPin pin) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AddPinForm(
          lat: pin.location.latitude,
          lng: pin.location.longitude,
          existingPin: pin.toMap(), 
          onSave: () {
            Navigator.pop(context);
            _loadPins();
          },
        ),
      ),
    );
      
  }
  void _deletePin(MapPin pin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar pin?'),
        content: const Text('Esta acción no se puede deshacer'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('map_pins')
          .delete()
          .eq('id', pin.id); // asegúrate de que el modelo MapPin tenga un campo `id`

      _loadPins(); // recarga los pines
    }
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
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void _loadPins() async {
    final pins = await fetchPinsFromSupabase();
    setState(() {
      _pins = pins;
    });
  }

  Future<List<MapPin>> fetchPinsFromSupabase() async {
    final response = await Supabase.instance.client.from('map_pins').select();
    return (response as List).map((row) => MapPin.fromMap(row)).toList();
  }

  void _handleTapOnMap(TapPosition tapPosition, LatLng latlng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AddPinForm(
          lat: latlng.latitude,
          lng: latlng.longitude,
          onSave: () {
            Navigator.pop(context);
            _loadPins();
          },
        ),
      ),
    );
  }

  Widget getPinIcon(String type) {
    String asset;
    switch (type) {
        case 'entrada':
          asset = 'assets/images/pins/entrance_pin.png';
          break;
        case 'museo':
          asset = 'assets/images/pins/museum_pin.png';
          break;
        case 'piramide':
          asset = 'assets/images/pins/pyramid_pin.png';
          break;
        default:
          asset = 'assets/images/pins/entrance_pin.png';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonR(
                    width: 150, 
                    text: 'Editar',
                    icon: Icons.edit,
                    color: AppColors.azulMedio,
                    onTap: () {
                      Navigator.pop(context);
                      _editPin(pin);
                    },
                  ),

                  ButtonR(
                    width: 150, 
                    text: 'Eliminar',
                    icon: Icons.delete,
                    color: AppColors.rojo,
                    onTap: () => _deletePin(pin),
                  ),


                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mbtiles?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Administrar puntos del parque'),
      ),
      body: FutureBuilder<MbTiles>(
        future: _futureMbtiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _mbtiles = snapshot.data;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      minZoom: 16,
                      maxZoom: 20,
                      initialZoom: 16,
                      initialCenter: const LatLng(0.054529, -78.305064),
                      onTap: _handleTapOnMap,
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
                              child: const Icon(Icons.my_location, color: Colors.blue),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
