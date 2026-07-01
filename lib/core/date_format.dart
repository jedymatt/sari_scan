import 'package:intl/intl.dart';

/// Formats a ledger entry timestamp as a localized date and time,
/// e.g. "Jul 1, 2026 2:30 PM".
final entryDateTimeFormat = DateFormat.yMMMd().add_jm();
