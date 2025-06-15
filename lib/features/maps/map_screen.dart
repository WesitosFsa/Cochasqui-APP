import 'dart:async';

import 'package:cochasqui_park/features/maps/map_controller.dart';
import 'package:cochasqui_park/features/maps/widgets/map_pin.dart';
import 'package:cochasqui_park/features/maps/widgets/watch_map_pins.dart';
import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:cochasqui_park/shared/widgets/buttonR.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cochasqui_park/core/powersync/powersync.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  final Future<MbTiles> _futureMbtiles = _initMbtiles();
  MbTiles? _mbtiles;
  LatLng? _currentPosition;
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  StreamSubscription<Position>? _positionStream;

  final uuid = const Uuid(); 

  static Future<MbTiles> _initMbtiles() async {
    final file = await copyAssetToFile('assets/maps/Cochasqui.mbtiles');
    return MbTiles(mbtilesPath: file.path);
  }

  @override
  void initState() {
    super.initState();
    _startListeningPosition();
    _checkInitialConnectivity();
    _setupConnectivityListener();

  }
  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectivityStatus(connectivityResult);
  }

  void _setupConnectivityListener() {

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectivityStatus(results);
    });
  }
  void _updateConnectivityStatus(List<ConnectivityResult> results) {

    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.bluetooth);

    if (_isConnected != hasConnection) {
      setState(() {
        _isConnected = hasConnection;
      });
    }
  }

  Future<void> _startListeningPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

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

  @override
  void dispose() {
    _mbtiles?.dispose();
    _positionStream?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget getPinIcon(String type, {bool visited = false}) {
    String asset;
    if (visited) {
      asset = 'assets/images/pins/visited_pin.png';
    } else {
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
              if (!pin.visited)
                ButtonR(
                  text: 'Marcar como visitado',
                  onTap: () async {
                    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                    final visitedAt = DateTime.now().toIso8601String(); 

                    if (currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Error: Usuario no autenticado para marcar pin.')),
                        );
                        return;
                    }
                    
                    final newVisitedPinId = uuid.v4();

                    try {
                      await db.execute(
                        '''
                        INSERT INTO visited_pins (id, user_id, pin_id, visited_at)
                        VALUES (?, ?, ?, ?)
                        ''',
                        [
                          newVisitedPinId, 
                          currentUserId,
                          pin.id,
                          visitedAt
                        ],
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Punto marcado como visitado')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al marcar pin: $e')),
                      );
                    }
                  },
                  color: AppColors.verde,
                  icon: Icons.check,
                ),
              const SizedBox(height: 10),
              ButtonR(
                text: 'Cerrar',
                onTap: () {
                  Navigator.pop(context);
                },
                color: Colors.grey,
                icon: Icons.close,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const Center(child: Text("Usuario no autenticado"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Mapa del Parque Cochasqui'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(
              _isConnected ? Icons.cloud : Icons.cloud_off,
              color: _isConnected ? Colors.grey : Colors.red.shade700,
              size: 28,
            ),
          ),
        ],
      ),
      body: FutureBuilder<MbTiles>(
        future: _futureMbtiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _mbtiles = snapshot.data;
            return StreamBuilder<List<MapPin>>(
              stream: watchMapPins(db, userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error cargando pines: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pins = snapshot.data!;
                return FlutterMap(
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
                      markers: pins.map((pin) {
                        return Marker(
                          point: pin.location,
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _showPinInfo(pin),
                            child: getPinIcon(pin.type, visited: pin.visited),
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
                );
              },
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