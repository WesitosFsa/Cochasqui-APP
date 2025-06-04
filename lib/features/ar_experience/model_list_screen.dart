import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'museum_screen.dart'; // La pantalla donde se visualiza el modelo en AR

class ModelListScreen extends StatefulWidget {
  final List<ARModel>
      models; // Aquí llegan tus modelos desde la BDD o una lista local

  const ModelListScreen({super.key, required this.models});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final categories = [
    'pirámides',
    'museo',
  ]; // Las categorías que quieres mostrar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modelos en AR"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          // Filtrar los modelos por categoría
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
                    // En lugar de mostrar SnackBar, abrimos QRScanner y le pasamos el modelo tocado
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
                  showDialog(
                    context: context,
                    builder: (_) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: Text("Adivinanza"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(model.riddle),
                            TextField(
                              controller: controller,
                              decoration:
                                  InputDecoration(labelText: 'Tu respuesta'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final userAnswer =
                                  controller.text.trim().toLowerCase();
                              final correctAnswer =
                                  model.answer.trim().toLowerCase();

                              Navigator.pop(context);
                              if (userAnswer == correctAnswer) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MuseumScreen(model: model),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Respuesta incorrecta, intenta de nuevo')),
                                );
                              }
                            },
                            child: Text("Comprobar"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: screenWidth * 0.6,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(model.imagePath), // Imagen de fondo
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
                      gradient: LinearGradient(
                        // ignore: deprecated_member_use
                        colors: [
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      model.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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
