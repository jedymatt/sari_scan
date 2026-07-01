import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart';
import 'package:sari_scan/db.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/pages/home_page.dart';
import 'package:sari_scan/pages/mga_utang/mga_utang_page.dart';

void main() {
  setUp(() {
    setDatabaseForTesting(AppDatabase.forTesting(NativeDatabase.memory()));
  });

  tearDown(resetDatabaseForTesting);

  testWidgets('tapping the Mga Utang card opens MgaUtangPage', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mga Utang'));
    await tester.pumpAndSettle();

    expect(find.byType(MgaUtangPage), findsOneWidget);
  });
}
