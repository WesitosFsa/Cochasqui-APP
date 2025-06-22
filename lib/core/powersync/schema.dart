import 'package:powersync/powersync.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

Schema schema = Schema(([
  const Table('feedback', [
    Column.text('user_id'), 
    Column.text('mensaje'),
    Column.text('created_at'), 
    Column.integer('leido'), 
  ], indexes: [
    Index('feedback_user_id', [IndexedColumn('user_id')])
  ]),

  const Table('ar_models', [
    Column.text('name'),
    Column.text('description'),
    Column.text('category'),
    Column.text('key'),
    Column.text('riddle'),
    Column.text('answer'),
  ]),

  const Table('map_pins', [

    Column.real('latitude'),
    Column.real('longitude'),
    Column.text('title'),
    Column.text('description'),
    Column.text('type'),
  ]),

  const Table('visited_pins', [
    Column.text('user_id'), 
    Column.integer('pin_id'), 
    Column.text('visited_at'), 
  ],
  indexes: [
    Index('visited_pins_user_pin', [IndexedColumn('user_id'), IndexedColumn('pin_id')])
  ]),
  AttachmentsQueueTable(
      attachmentsQueueTableName: defaultAttachmentsQueueTableName)
]));