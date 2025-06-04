import 'package:cochasqui_park/features/ar_experience/models/ARModelList.dart';
import 'package:flutter/material.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/model_list_screen.dart'; // tu pantalla actual


class ModelListLoaderScreen extends StatelessWidget {
  const ModelListLoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ARModel>>(
      future: fetchModelsFromSupabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final models = snapshot.data!;
          return ModelListScreen(models: models);
        }
      },
    );
  }
}
