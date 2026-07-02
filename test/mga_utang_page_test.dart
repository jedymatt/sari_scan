import 'dart:async';

import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart' show AppDatabase;
import 'package:sari_scan/db.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/models.dart';
import 'package:sari_scan/pages/mga_utang/mga_utang_page.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

/// Holds every SELECT while [hold] is set, so a test can render the frames
/// that appear before a reload finishes.
class _GatedSelects extends QueryInterceptor {
  Completer<void>? hold;

  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) async {
    final gate = hold;
    if (gate != null) await gate.future;
    return executor.runSelect(statement, args);
  }
}

void main() {
  late _GatedSelects gate;

  setUp(() {
    gate = _GatedSelects();
    setDatabaseForTesting(
      AppDatabase.forTesting(NativeDatabase.memory().interceptWith(gate)),
    );
  });
  tearDown(resetDatabaseForTesting);

  testWidgets('switching to the trash tab with active customers does not crash',
      (tester) async {
    await insertCustomer(Customer(name: 'Aling Rosa'));

    await tester.pumpWidget(_wrap(const MgaUtangPage()));
    await tester.pumpAndSettle();
    expect(find.text('Aling Rosa'), findsOneWidget);

    gate.hold = Completer<void>();
    await tester.tap(find.text('Trash'));
    // The reload is stuck on the gated SELECT, so this frame renders with
    // the trash tab selected but the active customer list still on screen.
    await tester.pump();
    expect(tester.takeException(), isNull);

    gate.hold!.complete();
    gate.hold = null;
    await tester.pumpAndSettle();
    expect(find.text('Aling Rosa'), findsNothing);
  });

  testWidgets('undo after move-to-trash restores the customer in the list',
      (tester) async {
    await insertCustomer(Customer(name: 'Aling Rosa'));

    await tester.pumpWidget(_wrap(const MgaUtangPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aling Rosa'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to Trash'));
    await tester.pumpAndSettle();

    expect(find.text('Aling Rosa'), findsNothing);
    expect(find.text('Moved to trash'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Aling Rosa'), findsOneWidget);
  });
}
