import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/core/trash.dart';

void main() {
  final now = DateTime(2026, 7, 1, 12);

  test('full retention remaining just after trashing', () {
    expect(daysUntilPurge(now, now), 30);
  });

  test('still shows full retention within the first day', () {
    final trashed = now.subtract(const Duration(hours: 1));
    expect(daysUntilPurge(trashed, now), 30);
  });

  test('mid-window rounds partial days up', () {
    // 10d5h elapsed leaves 19d19h; the customer survives into a 20th day.
    final trashed = now.subtract(const Duration(days: 10, hours: 5));
    expect(daysUntilPurge(trashed, now), 20);
  });

  test('exact whole days remaining are not rounded up', () {
    final trashed = now.subtract(const Duration(days: 10));
    expect(daysUntilPurge(trashed, now), 20);
  });

  test('past the cutoff clamps to zero', () {
    final trashed = now.subtract(const Duration(days: 31));
    expect(daysUntilPurge(trashed, now), 0);
  });
}
