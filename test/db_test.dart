import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart' show AppDatabase;
import 'package:sari_scan/db.dart';
import 'package:sari_scan/models.dart';

void main() {
  setUp(() {
    setDatabaseForTesting(AppDatabase.forTesting(NativeDatabase.memory()));
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

  test('archived customers are excluded from active and shown in archived',
      () async {
    final id = await insertCustomer(Customer(name: 'Aling Rosa'));
    await setCustomerArchived(id, true);
    expect(await queryCustomers(), isEmpty);
    final archived = await queryCustomers(archived: true);
    expect(archived, hasLength(1));
    expect(archived.single.customer.isArchived, isTrue);
  });

  test('adding a debt auto-unarchives the customer', () async {
    final id = await insertCustomer(Customer(name: 'Aling Rosa'));
    await setCustomerArchived(id, true);
    await insertEntry(customerId: id, type: UtangType.debt, amount: 50);
    expect(await queryCustomers(archived: true), isEmpty);
    final active = await queryCustomers();
    expect(active.single.balance, 50);
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
    await insertEntry(customerId: b, type: UtangType.payment, amount: 50); // -30
    expect(await totalOutstanding(), 100);
  });
}
