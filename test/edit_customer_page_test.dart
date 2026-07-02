import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/l10n/app_localizations.dart';
import 'package:sari_scan/pages/mga_utang/edit_customer_page.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('requires a name before saving', (tester) async {
    await tester.pumpWidget(_wrap(const EditCustomerPage()));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Please enter a name'), findsOneWidget);
  });
}
