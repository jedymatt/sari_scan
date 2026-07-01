import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/models.dart';
import 'package:sari_scan/pages/mga_utang/add_entry_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('shows validation error when amount is empty', (tester) async {
    await tester.pumpWidget(_wrap(const AddEntryForm(type: UtangType.debt)));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Please enter an amount'), findsOneWidget);
  });

  testWidgets('rejects a zero amount', (tester) async {
    await tester.pumpWidget(_wrap(const AddEntryForm(type: UtangType.debt)));
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
  });

  testWidgets('rejects a negative amount', (tester) async {
    await tester.pumpWidget(_wrap(const AddEntryForm(type: UtangType.debt)));
    await tester.enterText(find.byType(TextFormField).first, '-5');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
  });
}
