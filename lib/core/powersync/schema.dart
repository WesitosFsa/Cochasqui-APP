import 'package:powersync/powersync.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

Schema schema = Schema(([
  // Definición de la tabla 'feedback'
  const Table('feedback', [
    Column.text('user_id'), // UUID de Supabase se mapea a 'text'
    Column.text('mensaje'),
    Column.text('created_at'), // timestamp se mapea a 'text'
    Column.integer('leido'), // boolean se mapea a 'integer' (0 o 1)
  ], indexes: [
    Index('feedback_user_id', [IndexedColumn('user_id')])
  ]),

  // Definición de la tabla 'ar_models'
  const Table('ar_models', [
    Column.text('name'),
    Column.text('description'),
    Column.text('category'),
    Column.text('key'),
    Column.text('riddle'),
    Column.text('answer'),
  ]),

  // Definición de la tabla 'map_pins'
  // PowerSync gestionará automáticamente la columna 'id' porque es la clave primaria en Supabase.
  // ¡NO se define 'id' aquí!
  const Table('map_pins', [
    // Column.integer('id'), // <--- ¡ELIMINA ESTA LÍNEA! PowerSync la añade automáticamente.
    Column.real('latitude'),
    Column.real('longitude'),
    Column.text('title'),
    Column.text('description'),
    Column.text('type'),
  ]),

  // Definición de la tabla 'visited_pins'
  // Aquí sí definimos 'pin_id' como integer porque es una columna regular (no la PK de esta tabla)
  // y hace referencia a un ID INT de otra tabla.
  // Definición de la tabla 'visited_pins'
  const Table('visited_pins', [
    Column.text('user_id'), // UUID de Supabase se mapea a 'text' (Correcto)
    Column.integer('pin_id'), // Correcto: coincide con map_pins.id que es INT
    Column.text('visited_at'), // timestamp se mapea a 'text' (Correcto)
  ],
  indexes: [
    Index('visited_pins_user_pin', [IndexedColumn('user_id'), IndexedColumn('pin_id')])
  ]),
  // Tabla para manejar adjuntos de PowerSync
  AttachmentsQueueTable(
      attachmentsQueueTableName: defaultAttachmentsQueueTableName)
]));