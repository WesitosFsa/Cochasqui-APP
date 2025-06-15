import 'package:powersync/powersync.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

Schema schema = Schema(([
  // Definición de la tabla 'feedback'
  const Table('feedback', [ // ¡No se define 'id' aquí, PowerSync lo añade automáticamente!
    Column.text('user_id'), // UUID de Supabase se mapea a 'text'
    Column.text('mensaje'),
    Column.text('created_at'), // timestamp se mapea a 'text'
    Column.integer('leido'), // boolean se mapea a 'integer' (0 o 1)
  ], indexes: [
    Index('feedback_user_id', [IndexedColumn('user_id')])
  ]),

  // Definición de la tabla 'ar_models'
  const Table('ar_models', [ // ¡No se define 'id' aquí!
    Column.text('name'),
    Column.text('description'),
    Column.text('category'),
    Column.text('key'),
    Column.text('riddle'),
    Column.text('answer'),
  ]),

  // Definición de la tabla 'map_pins'
  const Table('map_pins', [ // ¡No se define 'id' aquí!
    Column.real('latitude'), // double precision se mapea a 'real'
    Column.real('longitude'),
    Column.text('title'),
    Column.text('description'),
    Column.text('type'),
  ]),

  // Definición de la tabla 'visited_pins'
  const Table('visited_pins', [ // ¡No se define 'id' aquí!
    Column.text('user_id'), // UUID de Supabase se mapea a 'text'
    Column.text('pin_id'), // Referencia a map_pins(id), que es 'text'
    Column.text('visited_at'), // timestamp se mapea a 'text'
  ], indexes: [
    Index('visited_pins_user_pin', [IndexedColumn('user_id'), IndexedColumn('pin_id')])
  ]),

  // Tabla para manejar adjuntos de PowerSync (mantener si la usas)
  AttachmentsQueueTable(
      attachmentsQueueTableName: defaultAttachmentsQueueTableName)
]));