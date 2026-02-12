// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'Sari Scan';

  @override
  String get greeting => 'Maayong adlaw!';

  @override
  String get totalProducts => 'Kinatibuk-ang Produkto';

  @override
  String get scanBarcode => 'I-scan ang Barcode';

  @override
  String get lookupProductPrices => 'Tan-awa ang presyo sa produkto';

  @override
  String get manageProducts => 'Pagdumala sa mga Produkto';

  @override
  String get addEditRemoveProducts =>
      'Idugang, usba, o tangtanga ang mga produkto';

  @override
  String get mgaUtang => 'Mga Utang';

  @override
  String get comingSoon => 'Moabot Na';

  @override
  String get settings => 'Mga Setting';

  @override
  String get appearance => 'Dagway';

  @override
  String get systemDefault => 'Default sa sistema';

  @override
  String get light => 'Hayag';

  @override
  String get dark => 'Ngitngit';

  @override
  String get pointCameraAtBarcode => 'Itutok ang camera sa barcode';

  @override
  String get productNotFound => 'Wala makitag produkto';

  @override
  String get barcode => 'Barcode';

  @override
  String barcodeWithValue(String value) {
    return 'Barcode: $value';
  }

  @override
  String get registerProduct => 'Irehistro ang Produkto';

  @override
  String get edit => 'Usba';

  @override
  String get editProduct => 'Usba ang Produkto';

  @override
  String get productName => 'Ngalan sa Produkto';

  @override
  String get price => 'Presyo';

  @override
  String get pleaseEnterProductName => 'Palihug isulod ang ngalan sa produkto';

  @override
  String get pleaseEnterPrice => 'Palihug isulod ang presyo';

  @override
  String get pleaseEnterValidNumber => 'Palihug isulod ang hustong numero';

  @override
  String get saveProduct => 'I-save ang Produkto';

  @override
  String get saveChanges => 'I-save ang mga Kausaban';

  @override
  String get deleteProduct => 'Tangtanga ang Produkto';

  @override
  String confirmDeleteProduct(String productName) {
    return 'Sigurado ka ba nga tangtangon ang \"$productName\"?';
  }

  @override
  String get cancel => 'Kanselahon';

  @override
  String get delete => 'Tangtanga';

  @override
  String productDeleted(String productName) {
    return 'Natangtang ang $productName';
  }

  @override
  String get searchByNameOrBarcode => 'Pangitaa pinaagi sa ngalan o barcode';

  @override
  String get noProductsYet => 'Walay produkto pa';

  @override
  String get scanBarcodeToAddFirstProduct =>
      'I-scan ang barcode aron makadugang sa imong unang produkto';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ka mga produkto',
      one: '1 ka produkto',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingProducts => 'Walay nakit-ang produkto';

  @override
  String get language => 'Pinulongan';

  @override
  String get english => 'English';

  @override
  String get cebuano => 'Binisaya';
}
