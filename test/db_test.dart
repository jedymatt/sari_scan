import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart' show AppDatabase, CustomersCompanion;
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    setDatabaseForTesting(db);
  });
  tearDown(resetDatabaseForTesting);

  test('new customer has zero balance and appears in active list', () async {
    await insertCustomer(Customer(name: 'Aling Rosa'));
    final active = await queryCustomers();
    expect(active, hasLength(1));
    expect(active.single.customer.name, 'Aling Rosa');
    expect(active.single.balance, 0);
  });

  test('balance reflects debts minus payments', () async {
    final id = await insertCustomer(Customer(name: 'Mang Juan'));
    await insertEntry(customerId: id, type: UtangType.debt, amount: 100);
    await insertEntry(customerId: id, type: UtangType.payment, amount: 30);
    final active = await queryCustomers();
    expect(active.single.balance, 70);
  });

  test('trashed customers are excluded from active and shown in trash',
      () async {
    final id = await insertCustomer(Customer(name: 'Aling Rosa'));
    await setCustomerTrashed(id, true);
    expect(await queryCustomers(), isEmpty);
    final trashed = await queryCustomers(trashed: true);
    expect(trashed, hasLength(1));
    expect(trashed.single.customer.isTrashed, isTrue);
  });

  test('adding a debt does NOT restore a trashed customer', () async {
    final id = await insertCustomer(Customer(name: 'Aling Rosa'));
    await setCustomerTrashed(id, true);
    await insertEntry(customerId: id, type: UtangType.debt, amount: 50);
    // Still trashed; entry recorded but the customer is not auto-restored.
    expect(await queryCustomers(), isEmpty);
    final trashed = await queryCustomers(trashed: true);
    expect(trashed.single.balance, 50);
  });

  test('restore clears the trashed state', () async {
    final id = await insertCustomer(Customer(name: 'Aling Rosa'));
    await setCustomerTrashed(id, true);
    await setCustomerTrashed(id, false);
    expect(await queryCustomers(), hasLength(1));
    expect(await queryCustomers(trashed: true), isEmpty);
  });

  test('deleting a customer removes their entries', () async {
    final id = await insertCustomer(Customer(name: 'Mang Juan'));
    await insertEntry(customerId: id, type: UtangType.debt, amount: 100);
    await deleteCustomer(id);
    expect(await queryCustomers(), isEmpty);
    expect(await queryEntries(id), isEmpty);
  });

  test('totalOutstanding sums only positive active balances', () async {
    final a = await insertCustomer(Customer(name: 'A'));
    final b = await insertCustomer(Customer(name: 'B'));
    await insertEntry(customerId: a, type: UtangType.debt, amount: 100);
    await insertEntry(customerId: b, type: UtangType.debt, amount: 20);
    await insertEntry(customerId: b, type: UtangType.payment, amount: 50);
    expect(await totalOutstanding(), 100);
  });

  test('purgeExpiredTrash removes customers trashed past the cutoff', () async {
    final old = await insertCustomer(Customer(name: 'Old'));
    await insertEntry(customerId: old, type: UtangType.debt, amount: 100);
    // Backdate its deletedAt to 31 days ago.
    await (db.update(db.customers)..where((c) => c.id.equals(old))).write(
      CustomersCompanion(
        deletedAt: Value(DateTime.now().subtract(const Duration(days: 31))),
      ),
    );

    final purged = await purgeExpiredTrash();
    expect(purged, 1);
    expect(await queryCustomers(trashed: true), isEmpty);
    expect(await queryEntries(old), isEmpty);
  });

  test('purgeExpiredTrash keeps recently trashed and active customers',
      () async {
    final recent = await insertCustomer(Customer(name: 'Recent'));
    await setCustomerTrashed(recent, true); // deletedAt = now
    await insertCustomer(Customer(name: 'Active'));

    final purged = await purgeExpiredTrash();
    expect(purged, 0);
    expect(await queryCustomers(trashed: true), hasLength(1));
    expect(await queryCustomers(), hasLength(1));
  });
}
