import 'package:drift/drift.dart';
import 'package:sari_scan/database.dart';
import 'package:sari_scan/models.dart' as models;

// Singleton database instance
AppDatabase? _database;

AppDatabase _getDatabase() {
  _database ??= AppDatabase();
  return _database!;
}

Future<List<models.Product>> queryProducts() async {
  final db = _getDatabase();
  final results = await db.select(db.products).get();

  return results.map((row) => models.Product(
    id: row.id,
    name: row.name,
    price: row.price,
    barcode: row.barcode,
  )).toList();
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
