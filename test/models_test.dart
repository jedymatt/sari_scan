import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/models.dart';

UtangEntry _entry(UtangType type, double amount) =>
    UtangEntry(customerId: 1, type: type, amount: amount);

void main() {
  group('balanceOf', () {
    test('no entries is zero', () {
      expect(balanceOf([]), 0);
    });

    test('debts add up', () {
      expect(balanceOf([_entry(UtangType.debt, 25), _entry(UtangType.debt, 15)]), 40);
    });

    test('payments subtract', () {
      expect(
        balanceOf([_entry(UtangType.debt, 100), _entry(UtangType.payment, 30)]),
        70,
      );
    });

    test('fully settled is zero', () {
      expect(
        balanceOf([_entry(UtangType.debt, 50), _entry(UtangType.payment, 50)]),
        0,
      );
    });

    test('overpayment goes negative', () {
      expect(
        balanceOf([_entry(UtangType.debt, 20), _entry(UtangType.payment, 30)]),
        -10,
      );
    });
  });
}
