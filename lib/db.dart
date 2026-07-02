import 'package:drift/drift.dart';
import 'package:sari_scan/database.dart';
import 'package:sari_scan/models.dart' as models;
import 'package:sari_scan/core/trash.dart';

// Singleton database instance
AppDatabase? _database;

AppDatabase _getDatabase() {
  _database ??= AppDatabase();
  return _database!;
}

/// Overrides the database instance for tests.
void setDatabaseForTesting(AppDatabase db) {
  _database = db;
}

/// Clears the test database override.
void resetDatabaseForTesting() {
  _database = null;
}

Future<List<models.Product>> queryProducts() async {
  final db = _getDatabase();
  final results = await db.select(db.products).get();

  return results
      .map((row) => models.Product(
            id: row.id,
            name: row.name,
            price: row.price,
            barcode: row.barcode,
          ))
      .toList();
}

Future<void> insertProduct(models.Product product) async {
  final db = _getDatabase();

  await db.into(db.products).insert(ProductsCompanion.insert(
        name: product.name,
        price: product.price.toDouble(),
        barcode: product.barcode,
      ));
}

Future<void> updateProduct(models.Product product) async {
  final db = _getDatabase();

  await (db.update(db.products)..where((p) => p.id.equals(product.id!)))
      .write(ProductsCompanion(
    name: Value(product.name),
    price: Value(product.price.toDouble()),
    barcode: Value(product.barcode),
  ));
}

Future<void> deleteProduct(int id) async {
  final db = _getDatabase();

  await (db.delete(db.products)..where((p) => p.id.equals(id))).go();
}

Future<List<models.CustomerWithBalance>> queryCustomers(
    {bool trashed = false}) async {
  final db = _getDatabase();
  final customers = db.customers;
  final entries = db.utangEntries;

  final debtSum = entries.amount
      .sum(filter: entries.type.equalsValue(models.UtangType.debt));
  final paymentSum = entries.amount
      .sum(filter: entries.type.equalsValue(models.UtangType.payment));
  final balance = coalesce([debtSum, const Constant(0.0)]) -
      coalesce([paymentSum, const Constant(0.0)]);

  final query = db.select(customers).join([
    leftOuterJoin(entries, entries.customerId.equalsExp(customers.id),
        useColumns: false),
  ])
    ..where(trashed ? customers.deletedAt.isNotNull() : customers.deletedAt.isNull())
    ..groupBy([customers.id])
    ..orderBy([OrderingTerm.asc(customers.name.collate(Collate.noCase))])
    ..addColumns([balance]);

  final rows = await query.get();
  return rows.map((row) {
    return models.CustomerWithBalance(
      customer: _toCustomer(row.readTable(customers)),
      balance: models.roundToCentavos(row.read(balance) ?? 0),
    );
  }).toList();
}

/// Looks up a single customer by id, whether active or trashed.
Future<models.Customer?> getCustomer(int id) async {
  final db = _getDatabase();
  final row = await (db.select(db.customers)..where((c) => c.id.equals(id)))
      .getSingleOrNull();
  return row == null ? null : _toCustomer(row);
}

/// Returns the names of all active (non-trashed) customers, optionally
/// excluding the customer with [excludeId] (useful when editing so a
/// customer doesn't match against itself).
Future<List<String>> activeCustomerNames({int? excludeId}) async {
  final db = _getDatabase();

  final rows =
      await (db.select(db.customers)..where((c) => c.deletedAt.isNull())).get();
  return rows
      .where((r) => r.id != excludeId)
      .map((r) => r.name)
      .toList();
}

Future<int> insertCustomer(models.Customer customer) {
  final db = _getDatabase();
  return db.into(db.customers).insert(CustomersCompanion.insert(
        name: customer.name,
        phone: Value(customer.phone),
      ));
}

Future<void> updateCustomer(models.Customer customer) async {
  final db = _getDatabase();
  await (db.update(db.customers)..where((c) => c.id.equals(customer.id!)))
      .write(CustomersCompanion(
    name: Value(customer.name),
    phone: Value(customer.phone),
  ));
}

Future<void> deleteCustomer(int id) async {
  final db = _getDatabase();
  await db.transaction(() async {
    await (db.delete(db.utangEntries)..where((e) => e.customerId.equals(id)))
        .go();
    await (db.delete(db.customers)..where((c) => c.id.equals(id))).go();
  });
}

/// Permanently deletes customers (and their entries) that have been in the
/// trash longer than [retention]. Returns the number of customers purged.
Future<int> purgeExpiredTrash({Duration retention = trashRetention}) async {
  final db = _getDatabase();
  final cutoff = DateTime.now().subtract(retention);
  return db.transaction(() async {
    final expired = await (db.select(db.customers)
          ..where((c) => c.deletedAt.isSmallerThanValue(cutoff)))
        .get();
    if (expired.isEmpty) return 0;
    final ids = expired.map((c) => c.id).toList();
    await (db.delete(db.utangEntries)..where((e) => e.customerId.isIn(ids)))
        .go();
    await (db.delete(db.customers)..where((c) => c.id.isIn(ids))).go();
    return ids.length;
  });
}

Future<void> setCustomerTrashed(int id, bool trashed) async {
  final db = _getDatabase();
  await (db.update(db.customers)..where((c) => c.id.equals(id))).write(
    CustomersCompanion(
      deletedAt: Value(trashed ? DateTime.now() : null),
    ),
  );
}

Future<List<models.UtangEntry>> queryEntries(int customerId) async {
  final db = _getDatabase();
  final rows = await (db.select(db.utangEntries)
        ..where((e) => e.customerId.equals(customerId))
        ..orderBy([
          (e) => OrderingTerm.desc(e.createdAt),
          (e) => OrderingTerm.desc(e.id),
        ]))
      .get();
  return rows.map(_toEntry).toList();
}

Future<void> insertEntry({
  required int customerId,
  required models.UtangType type,
  required double amount,
  String? note,
}) async {
  final db = _getDatabase();
  await db.into(db.utangEntries).insert(UtangEntriesCompanion.insert(
        customerId: customerId,
        type: type,
        amount: amount,
        note: Value(note),
      ));
}

Future<double> totalOutstanding() async {
  final withBalance = await queryCustomers();
  var total = 0.0;
  for (final c in withBalance) {
    if (c.balance > 0) total += c.balance;
  }
  return total;
}

models.Customer _toCustomer(Customer row) => models.Customer(
      id: row.id,
      name: row.name,
      phone: row.phone,
      deletedAt: row.deletedAt,
      createdAt: row.createdAt,
    );

models.UtangEntry _toEntry(UtangEntry row) => models.UtangEntry(
      id: row.id,
      customerId: row.customerId,
      type: row.type,
      amount: row.amount,
      note: row.note,
      createdAt: row.createdAt,
    );
