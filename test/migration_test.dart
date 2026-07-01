import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari_scan/database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('v1 -> v2 migration keeps products and creates new tables', () async {
    // Build a v1-shaped database by hand.
    final raw = sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 1;');
    raw.execute(
      'CREATE TABLE "products" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"name" TEXT NOT NULL, '
      '"price" REAL NOT NULL, '
      '"barcode" TEXT NOT NULL);',
    );
    raw.execute(
      "INSERT INTO products (name, price, barcode) "
      "VALUES ('Coke', 25.0, '123456');",
    );

    // Opening AppDatabase over this connection runs onUpgrade(1, 2).
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // Existing product survived the migration.
    final products = await db.select(db.products).get();
    expect(products, hasLength(1));
    expect(products.single.name, 'Coke');

    // New tables exist and are writable.
    final customerId = await db.into(db.customers).insert(
          CustomersCompanion.insert(name: 'Aling Rosa'),
        );
    final customers = await db.select(db.customers).get();
    expect(customers.single.id, customerId);
  });
}
