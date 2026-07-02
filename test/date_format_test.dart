import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sari_scan/core/date_format.dart';

void main() {
  // The app gets this from flutter_localizations' delegates at startup.
  setUpAll(initializeDateFormatting);

  final moment = DateTime(2026, 7, 1, 14, 4);

  // CLDR puts a narrow no-break space (U+202F) before AM/PM.
  String time(Locale locale) =>
      entryTimeFormat(locale).format(moment).replaceAll(' ', ' ');

  test('formats dates and times for a supported locale', () {
    expect(entryDateFormat(const Locale('en')).format(moment), 'Jul 1, 2026');
    expect(time(const Locale('en')), '2:04 PM');
  });

  test('falls back to the default locale when intl lacks the locale', () {
    expect(entryDateFormat(const Locale('ceb')).format(moment), 'Jul 1, 2026');
    expect(time(const Locale('ceb')), '2:04 PM');
  });
}
