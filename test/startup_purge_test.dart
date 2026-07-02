import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart' show AppDatabase;
import 'package:sari_scan/db.dart';
import 'package:sari_scan/main.dart' show purgeTrashAtStartup;

/// Simulates a corrupt database: every query fails.
class _BrokenDatabase extends QueryInterceptor {
  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) {
    throw StateError('database is corrupt');
  }
}

void main() {
  tearDown(resetDatabaseForTesting);

  test('startup purge reports instead of throwing on a broken database',
      () async {
    setDatabaseForTesting(AppDatabase.forTesting(
        NativeDatabase.memory().interceptWith(_BrokenDatabase())));

    final reported = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reported.add;
    try {
      await expectLater(purgeTrashAtStartup(), completes);
    } finally {
      FlutterError.onError = previousOnError;
    }
    expect(reported, hasLength(1));
  });

  test('startup purge still purges on a healthy database', () async {
    setDatabaseForTesting(AppDatabase.forTesting(NativeDatabase.memory()));
    await expectLater(purgeTrashAtStartup(), completes);
  });
}
