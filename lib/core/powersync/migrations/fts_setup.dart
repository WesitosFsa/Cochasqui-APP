import 'package:cochasqui_park/core/powersync/migrations/helpers.dart';
import 'package:cochasqui_park/core/powersync/schema.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite_async.dart';


final migrations = SqliteMigrations();

/// Crea una tabla de Búsqueda de Texto Completo (FTS) para la tabla y columnas dadas,
/// con una opción para usar un tokenizador diferente (por defecto 'unicode61').
/// También crea los disparadores (triggers) que mantienen la tabla FTS
/// y la tabla de PowerSync sincronizadas.
SqliteMigration createFtsMigration(
    {required int migrationVersion,
    required String tableName,
    required List<String> columns,
    String tokenizationMethod = 'unicode61'}) {
  // Asegúrate de que el schema.tables contenga la tabla para obtener el internalName.
  // PowerSync usa 'internalName' para las tablas subyacentes.
  String internalName =
      schema.tables.firstWhere((table) => table.name == tableName).internalName;
  String stringColumns = columns.join(', '); // Une las columnas para la cláusula SQL.

  return SqliteMigration(migrationVersion, (tx) async {
    // 1. Añade la tabla FTS (Virtual Table con fts5).
    // 'id UNINDEXED' significa que la columna 'id' no se indexa para la búsqueda,
    // solo se usa para referenciar el registro original.
    await tx.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS fts_$tableName
      USING fts5(id UNINDEXED, $stringColumns, tokenize='$tokenizationMethod');
    ''');
    // 2. Copia los registros ya existentes en la tabla original a la tabla FTS.
    // 'rowid' es el ID interno de SQLite, usado para mantener la correlación.
    await tx.execute('''
      INSERT INTO fts_$tableName(rowid, id, $stringColumns)
      SELECT rowid, id, ${generateJsonExtracts(ExtractType.columnOnly, 'data', columns)} FROM $internalName;
    ''');
    // 3. Añade disparadores (triggers) para INSERT, UPDATE y DELETE
    // para mantener la tabla FTS sincronizada con la tabla original.

    // Disparador para INSERT: Cuando se inserta un nuevo registro en la tabla original,
    // también se inserta en la tabla FTS.
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
    // Disparador para UPDATE: Cuando se actualiza un registro en la tabla original,
    // también se actualiza en la tabla FTS.
    await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS fts_update_trigger_$tableName AFTER UPDATE ON $internalName BEGIN
        UPDATE fts_$tableName
        SET ${generateJsonExtracts(ExtractType.columnInOperation, 'NEW.data', columns)} 
        WHERE rowid = NEW.rowid; 
      END;
    ''');
    // Disparador para DELETE: Cuando se elimina un registro de la tabla original,
    // también se elimina de la tabla FTS.
    await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS fts_delete_trigger_$tableName AFTER DELETE ON $internalName BEGIN
        DELETE FROM fts_$tableName WHERE rowid = OLD.rowid; 
      END;
    ''');
  });
}

/// Función principal para configurar las migraciones FTS.
/// Aquí es donde se añaden todas las migraciones FTS para las tablas.
Future<void> configureFts(PowerSyncDatabase db) async {
  migrations
    // Añade una migración FTS para la tabla 'feedback'.
    ..add(createFtsMigration(
      migrationVersion: 1, // Versión de la migración. Debe ser única y creciente.
      tableName: 'feedback',
      columns: ['mensaje'], // Columnas de 'feedback' en las que se realizará la búsqueda.
    ))
    // Añade una migración FTS para la tabla 'ar_models'.
    ..add(createFtsMigration(
      migrationVersion: 2, // Siguiente versión.
      tableName: 'ar_models',
      // Columnas relevantes para la búsqueda en 'ar_models'.
      columns: ['name', 'description', 'riddle', 'answer'],
      tokenizationMethod: 'porter unicode61', // Un tokenizador más avanzado.
    ))
    // Añade una migración FTS para la tabla 'map_pins'.
    ..add(createFtsMigration(
      migrationVersion: 3, // Siguiente versión.
      tableName: 'map_pins',
      // Columnas relevantes para la búsqueda en 'map_pins'.
      columns: ['title', 'description'],
    ))
    // NUEVA MIGRACIÓN FTS para la tabla 'visited_pins'.
    ..add(createFtsMigration(
      migrationVersion: 4, // Asegúrate de que esta sea la siguiente versión disponible.
      tableName: 'visited_pins',
      // Se pueden buscar por 'user_id' y 'pin_id' para encontrar visitas específicas.
      columns: ['user_id', 'pin_id'],
      // 'unicode61' es un buen tokenizador general para IDs.
      tokenizationMethod: 'unicode61',
    ));
  // Ejecuta todas las migraciones añadidas en la base de datos de PowerSync.
  await migrations.migrate(db);
}
