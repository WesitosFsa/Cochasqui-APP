import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
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
      body: ARView(
        onARViewCreated: onARViewCreated,
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
