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

  group('Customer.copyWith', () {
    final baseCustomer = Customer(
      id: 1,
      name: 'Rosa',
      phone: '0917',
      archivedAt: DateTime(2026, 1, 1),
    );

    test('with no args preserves existing phone and archivedAt', () {
      final result = baseCustomer.copyWith();
      expect(result.phone, '0917');
      expect(result.archivedAt, DateTime(2026, 1, 1));
    });

    test('clearPhone: true sets phone to null', () {
      final result = baseCustomer.copyWith(clearPhone: true);
      expect(result.phone, null);
      expect(result.archivedAt, DateTime(2026, 1, 1));
    });

    test('clearArchivedAt: true sets archivedAt to null', () {
      final result = baseCustomer.copyWith(clearArchivedAt: true);
      expect(result.phone, '0917');
      expect(result.archivedAt, null);
    });

    test('phone parameter overwrites without needing clear flag', () {
      final result = baseCustomer.copyWith(phone: '0918');
      expect(result.phone, '0918');
      expect(result.archivedAt, DateTime(2026, 1, 1));
    });

    test('name parameter changes name while leaving other fields unchanged', () {
      final result = baseCustomer.copyWith(name: 'Maria');
      expect(result.name, 'Maria');
      expect(result.phone, '0917');
      expect(result.archivedAt, DateTime(2026, 1, 1));
      expect(result.id, 1);
    });
  });
}
