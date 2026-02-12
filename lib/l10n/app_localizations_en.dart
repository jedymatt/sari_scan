// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sari Scan';

  @override
  String get greeting => 'Good day!';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get lookupProductPrices => 'Look up product prices';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get addEditRemoveProducts => 'Add, edit, or remove products';

  @override
  String get mgaUtang => 'Mga Utang';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get pointCameraAtBarcode => 'Point camera at a barcode';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get barcode => 'Barcode';

  @override
  String barcodeWithValue(String value) {
    return 'Barcode: $value';
  }

  @override
  String get registerProduct => 'Register Product';

  @override
  String get edit => 'Edit';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get price => 'Price';

  @override
  String get pleaseEnterProductName => 'Please enter a product name';

  @override
  String get pleaseEnterPrice => 'Please enter a price';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String confirmDeleteProduct(String productName) {
    return 'Are you sure you want to delete \"$productName\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String productDeleted(String productName) {
    return '$productName deleted';
  }

  @override
  String get searchByNameOrBarcode => 'Search by name or barcode';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get scanBarcodeToAddFirstProduct =>
      'Scan a barcode to add your first product';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get cebuano => 'Cebuano';
}
