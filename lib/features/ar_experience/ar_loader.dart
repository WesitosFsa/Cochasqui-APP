import 'package:cochasqui_park/core/powersync/powersync.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARLocales.dart'; // Si ARLocales no se usa, puedes quitar esta importación
import 'package:flutter/material.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/model_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Necesario para interactuar directamente con Supabase

class ModelListLoaderScreen extends StatelessWidget {
  const ModelListLoaderScreen({super.key});


  Future<List<ARModel>> _fetchPublicARModelsFromSupabase() async {
    try {

      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('ar_models')
          .select('id, name, description, category, key, riddle, answer');



      return data.map((item) {

        return ARModel(
          id: item['id'].toString(), 
          name: item['name'] as String,
          description: item['description'] as String,
          category: item['category'] as String,
          key: item['key'] as String,
          riddle: item['riddle'] as String,
          answer: item['answer'] as String,
          unlocked: false, 
        );
      }).toList();
    // ignore: unused_catch_clause
    } on PostgrestException catch (e) {
      return []; 
    } catch (e) {
      return []; 
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    if (isLoggedIn) {
      return StreamBuilder<List<ARModel>>(
        stream: watchARModels(db), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error al cargar modelos: ${snapshot.error}')),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No hay modelos disponibles (logueado).')),
            );
          } else {
            final models = snapshot.data!;
            return ModelListScreen(models: models);
          }
        },
      );
    } else {
      return FutureBuilder<List<ARModel>>(
        future: _fetchPublicARModelsFromSupabase(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error al cargar modelos: ${snapshot.error}')),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No hay modelos disponibles (invitado).')),
            );
          } else {
            final models = snapshot.data!;
            return ModelListScreen(models: models);
          }
        },
      );
    }
  }
}