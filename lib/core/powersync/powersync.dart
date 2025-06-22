import 'package:cochasqui_park/core/app_config.dart';
import 'package:cochasqui_park/core/powersync/migrations/fts_setup.dart';
import 'package:cochasqui_park/core/powersync/schema.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:logging/logging.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final log = Logger('powersync-supabase');

final List<RegExp> fatalResponseCodes = [
  RegExp(r'^22...$'),
  RegExp(r'^23...$'),
  RegExp(r'^42501$'),
];

class SupabaseConnector extends PowerSyncBackendConnector {
  Future<void>? _refreshFuture;

  SupabaseConnector();

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    await _refreshFuture;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return null;
    }

    final token = session.accessToken;

    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    return PowerSyncCredentials(
        endpoint: AppConfig.powersyncUrl,
        token: token,
        userId: userId,
        expiresAt: expiresAt);
  }

  @override
  void invalidateCredentials() {

    _refreshFuture = Supabase.instance.client.auth
        .refreshSession()
        .timeout(const Duration(seconds: 5))
        .then((response) => null, onError: (error) => null);
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {

    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;
    try {

      for (var op in transaction.crud) {
        lastOp = op;

        final table = rest.from(op.table);
        if (op.op == UpdateType.put) {
          var data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;
          await table.upsert(data);
        } else if (op.op == UpdateType.patch) {
          await table.update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await table.delete().eq('id', op.id);
        }
      }

      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null &&
          fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {

        log.severe('Data upload error - discarding $lastOp', e);
        await transaction.complete();
      } else {

        rethrow;
      }
    }
  }
}

late final PowerSyncDatabase db;

bool isLoggedIn() {
  return Supabase.instance.client.auth.currentSession?.accessToken != null;
}

String? getUserId() {
  return Supabase.instance.client.auth.currentSession?.user.id;
}

Future<String> getDatabasePath() async {
  const dbFilename = 'cochasqui_base_de_datos.db';
  if (kIsWeb) {
    return dbFilename;
  }
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, dbFilename);
}

Future<void> openDatabase() async {
  db = PowerSyncDatabase(
      schema: schema, path: await getDatabasePath(), logger: attachedLogger);
  await db.initialize();


  SupabaseConnector? currentConnector;

  if (isLoggedIn()) {
    currentConnector = SupabaseConnector();
    db.connect(connector: currentConnector);
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      currentConnector = SupabaseConnector();
      db.connect(connector: currentConnector!);
    } else if (event == AuthChangeEvent.signedOut) {
      currentConnector = null;
      await db.disconnect();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      currentConnector?.prefetchCredentials();
    }
  });

  await configureFts(db);
}

Future<void> logout() async {
  await Supabase.instance.client.auth.signOut();
  await db.disconnectAndClear();
}
