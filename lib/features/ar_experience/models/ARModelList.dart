import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';

Future<List<ARModel>> fetchModelsFromSupabase() async {
  final response = await Supabase.instance.client
      .from('ar_models')
      .select();

  // ignore: unnecessary_type_check
  if (response is List) {
    return response.map((item) => ARModel.fromJson(item)).toList();
  } else {
    throw Exception("Error al cargar modelos de Supabase");
  }
}
