import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:flutter/material.dart';
import 'museum_screen.dart';     // La pantalla donde se visualiza el modelo en AR

class ModelListScreen extends StatefulWidget {
  final List<ARModel> models; // Aquí llegan tus modelos desde la BDD o una lista local

  const ModelListScreen({super.key, required this.models});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final categories = ['pirámides', 'museo', 'camping']; // Las categorías que quieres mostrar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          final filtered = widget.models.where((m) => m.category == category).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final model = filtered[index];

              return GestureDetector(
                onTap: () {
                  // Al hacer tap, te manda a la pantalla de AR
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MuseumScreen(model: model),
                    ),
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
                    boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      model.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
