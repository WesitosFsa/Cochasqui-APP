import 'package:cochasqui_park/core/powersync/powersync.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARLocales.dart';
import 'package:flutter/material.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/model_list_screen.dart'; 


class ModelListLoaderScreen extends StatelessWidget {
  const ModelListLoaderScreen({super.key});

@override
Widget build(BuildContext context) {
  return StreamBuilder<List<ARModel>>(
    stream: watchARModels(db),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else {
        final models = snapshot.data!;
        return ModelListScreen(models: models);
      }
    },
  );
}
}
