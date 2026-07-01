import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/core/trash.dart';

void main() {
  final now = DateTime(2026, 7, 1, 12);

  test('full retention remaining just after trashing', () {
    expect(daysUntilPurge(now, now), 30);
  });

  test('mid-window rounds down to whole days remaining', () {
    final trashed = now.subtract(const Duration(days: 10, hours: 5));
    expect(daysUntilPurge(trashed, now), 19);
  });

  test('past the cutoff clamps to zero', () {
    final trashed = now.subtract(const Duration(days: 31));
    expect(daysUntilPurge(trashed, now), 0);
  });
}
