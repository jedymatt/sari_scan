import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// Calendar date for a ledger entry in [locale], e.g. "Jul 1, 2026".
DateFormat entryDateFormat(Locale locale) => DateFormat.yMMMd(_intl(locale));

/// Time of day for a ledger entry in [locale], e.g. "2:04 PM".
DateFormat entryTimeFormat(Locale locale) => DateFormat.jm(_intl(locale));

/// intl has no date patterns for some app locales (e.g. Cebuano); fall back
/// to the Intl default instead of letting DateFormat throw.
String? _intl(Locale locale) {
  final tag = locale.toLanguageTag();
  return DateFormat.localeExists(tag) ? tag : null;
}
