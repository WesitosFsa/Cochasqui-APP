import 'package:cochasqui_park/core/powersync/migrations/helpers.dart';
import 'package:cochasqui_park/core/powersync/schema.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite_async.dart';


final migrations = SqliteMigrations();

SqliteMigration createFtsMigration(
    {required int migrationVersion,
    required String tableName,
    required List<String> columns,
    String tokenizationMethod = 'unicode61'}) {
  String internalName =
      schema.tables.firstWhere((table) => table.name == tableName).internalName;
  String stringColumns = columns.join(', '); 

  return SqliteMigration(migrationVersion, (tx) async {
    await tx.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS fts_$tableName
      USING fts5(id UNINDEXED, $stringColumns, tokenize='$tokenizationMethod');
    ''');
    await tx.execute('''
      INSERT INTO fts_$tableName(rowid, id, $stringColumns)
      SELECT rowid, id, ${generateJsonExtracts(ExtractType.columnOnly, 'data', columns)} FROM $internalName;
    ''');

    await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS fts_insert_trigger_$tableName AFTER INSERT ON $internalName
      BEGIN
        INSERT INTO fts_$tableName(rowid, id, $stringColumns)
        VALUES (
          NEW.rowid, 
          NEW.id,    
          ${generateJsonExtracts(ExtractType.columnOnly, 'NEW.data', columns)} 
        );
      END;
    ''');
    await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS fts_update_trigger_$tableName AFTER UPDATE ON $internalName BEGIN
        UPDATE fts_$tableName
        SET ${generateJsonExtracts(ExtractType.columnInOperation, 'NEW.data', columns)} 
        WHERE rowid = NEW.rowid; 
      END;
    ''');
    await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS fts_delete_trigger_$tableName AFTER DELETE ON $internalName BEGIN
        DELETE FROM fts_$tableName WHERE rowid = OLD.rowid; 
      END;
    ''');
  });
}
Future<void> configureFts(PowerSyncDatabase db) async {
  migrations
    ..add(createFtsMigration(
      migrationVersion: 1, 
      tableName: 'feedback',
      columns: ['mensaje'], 
    ))
    ..add(createFtsMigration(
      migrationVersion: 2, 
      tableName: 'ar_models',
      columns: ['name', 'description', 'riddle', 'answer'],
      tokenizationMethod: 'porter unicode61', 
    ))
    ..add(createFtsMigration(
      migrationVersion: 3, 
      tableName: 'map_pins',
      columns: ['title', 'description'],
    ))
    ..add(createFtsMigration(
      migrationVersion: 4, 
      tableName: 'visited_pins',
      columns: ['user_id', 'pin_id'],
      tokenizationMethod: 'unicode61',
    ));
  await migrations.migrate(db);
}
