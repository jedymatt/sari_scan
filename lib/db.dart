import 'package:sari_scan/models.dart';
import 'package:sqflite/sqflite.dart';

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price REAL,
      barcode TEXT
    )
  ''');
}

Future<Database> getDbClient() async {
  // await deleteDatabase('sari_scan.db');
  var db = await openDatabase(
    'sari_scan.db',
    onCreate: _onCreate,
    version: 1,
  );

  return db;
}

Future<List<Product>> queryProducts() async {
  var db = await getDbClient();

  final productsMap = await db.query('products');

  return productsMap.map((e) => Product.fromMap(e)).toList();
}

Future<void> insertProduct(Product product) async {
  var db = await getDbClient();

  await db.insert(
    'products',
    product.toMap(),
  );
}

Future<void> updateProduct(Product product) async {
  var db = await getDbClient();

  await db.update(
    'products',
    product.toMap(),
    where: 'id = ?',
    whereArgs: [product.id],
  );
}

Future<void> deleteProduct(int id) async {
  var db = await getDbClient();

  await db.delete(
    'products',
    where: 'id = ?',
    whereArgs: [id],
  );
}
