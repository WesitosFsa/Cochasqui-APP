import 'package:powersync/powersync.dart';
import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';

Stream<List<ARModel>> watchARModels(PowerSyncDatabase db) {
  return db.watch('''
    SELECT id, name, description, category, key, riddle, answer
    FROM ar_models
  ''').map((rows) {
    return rows.map((row) => ARModel(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      category: row['category'] as String,
      key: row['key'] as String,
      riddle: row['riddle'] as String,
      answer: row['answer'] as String,
    )).toList();
  });
}
