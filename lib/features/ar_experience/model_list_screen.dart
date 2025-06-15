import 'dart:async';

import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/museum_screen.dart';
import 'package:cochasqui_park/features/ar_experience/qr_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ModelListScreen extends StatefulWidget {
  final List<ARModel> models;

  const ModelListScreen({super.key, required this.models});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final categories = ['pirámides', 'museo'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _checkInitialConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectivityStatus);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.bluetooth);

    if (_isConnected != hasConnection) {
      setState(() {
        _isConnected = hasConnection;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modelos en AR"),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final filtered =
              widget.models.where((m) => m.category == category).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final model = filtered[index];
              return GestureDetector(
                onTap: () {
                  if (!model.unlocked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QRScannerScreen(model: model),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MuseumScreen(model: model),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(model.imagePath),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(blurRadius: 8, color: Colors.black26)
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      model.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}