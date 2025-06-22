import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/models/ar_node.dart';
import 'package:ar_flutter_plugin_updated/datatypes/node_types.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';

class MuseumScreen extends StatefulWidget {
  final ARModel model;

  const MuseumScreen({super.key, required this.model});

  @override
  State<MuseumScreen> createState() => _MuseumScreenState();
}

class _MuseumScreenState extends State<MuseumScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? node;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.model.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width, 
              height: MediaQuery.of(context).size.height *
                  0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    20), 
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ARView(
                  onARViewCreated: onARViewCreated,
                ),
              ),
            ),
            const SizedBox(
                height: 30), 


            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informacion:",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.model.description, 
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Volver a la pantalla principal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(showPlanes: true);
    arObjectManager.onInitialize();

    addModel();
  }

  Future<void> addModel() async {
    if (node != null) {
      arObjectManager.removeNode(node!);
      node = null;
    }

    var newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: widget.model.gltfPath,
      scale: Vector3(0.2, 0.2, 0.2),
      position: Vector3(0.0, 0.0, -1.0),
      rotation: Vector4(1.0, 0.0, 0.0, 0.0),
    );

    bool? didAdd = await arObjectManager.addNode(newNode);
    if (didAdd == true) {
      node = newNode;
    }
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }
}
