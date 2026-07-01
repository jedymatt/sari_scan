import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Sari Scan'**
  String get appTitle;

  /// Greeting message on home page
  ///
  /// In en, this message translates to:
  /// **'Good day!'**
  String get greeting;

  /// Label for product count card
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// Label for scan barcode action
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Subtitle for scan barcode action
  ///
  /// In en, this message translates to:
  /// **'Look up product prices'**
  String get lookupProductPrices;

  /// Label for manage products action
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

  /// Subtitle for manage products action
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove products'**
  String get addEditRemoveProducts;

  /// Credit tracking feature label (Filipino term)
  ///
  /// In en, this message translates to:
  /// **'Mga Utang'**
  String get mgaUtang;

  /// Placeholder for upcoming features
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme option for system default
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Hint shown when no barcode is detected
  ///
  /// In en, this message translates to:
  /// **'Point camera at a barcode'**
  String get pointCameraAtBarcode;

  /// Message when scanned barcode has no product
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// Barcode label
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// Barcode label with value
  ///
  /// In en, this message translates to:
  /// **'Barcode: {value}'**
  String barcodeWithValue(String value);

  /// Register product button and page title
  ///
  /// In en, this message translates to:
  /// **'Register Product'**
  String get registerProduct;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Edit product page title
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Product name field label
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Validation error for empty product name
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get pleaseEnterProductName;

  /// Validation error for empty price
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get pleaseEnterPrice;

  /// Validation error for invalid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Save button for new product
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// Save button for editing product
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Delete product button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// Confirmation message for deleting product
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"?'**
  String confirmDeleteProduct(String productName);

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Snackbar message after deleting product
  ///
  /// In en, this message translates to:
  /// **'{productName} deleted'**
  String productDeleted(String productName);

  /// Search field hint text
  ///
  /// In en, this message translates to:
  /// **'Search by name or barcode'**
  String get searchByNameOrBarcode;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode to add your first product'**
  String get scanBarcodeToAddFirstProduct;

  /// Product count with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String productCount(int count);

  /// Empty search results message
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get noMatchingProducts;

  /// Language settings section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Cebuano language option
  ///
  /// In en, this message translates to:
  /// **'Cebuano'**
  String get cebuano;

  /// Subtitle for the Mga Utang home card
  ///
  /// In en, this message translates to:
  /// **'Track customer debts'**
  String get mgaUtangSubtitle;

  /// Empty state title for customer list
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Add a customer to start tracking utang'**
  String get addFirstCustomer;

  /// Customer search hint
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get searchCustomers;

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No matching customers'**
  String get noMatchingCustomers;

  /// Label for total owed
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding'**
  String get totalOutstanding;

  /// Active customers filter
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Trash customers filter
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// Add customer title
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// Edit customer title
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// Customer name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customerName;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterCustomerName;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// Save customer button
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// Add debt button
  ///
  /// In en, this message translates to:
  /// **'Add Utang'**
  String get addUtang;

  /// Add payment button
  ///
  /// In en, this message translates to:
  /// **'Add Bayad'**
  String get addBayad;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Zero balance label
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Amount required error
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// Amount positivity error
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get pleaseEnterValidAmount;

  /// Note field label
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Move a customer to trash
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get moveToTrash;

  /// Restore a customer from trash
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Permanently delete a trashed customer
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// Snackbar after moving a customer to trash
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get movedToTrash;

  /// Undo action label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Snackbar after restoring a customer
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// Countdown until a trashed customer is purged
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Deletes today} =1{Deletes in 1 day} other{Deletes in {count} days}}'**
  String deletesInDays(int count);

  /// Empty state for the trash tab
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get noTrashedCustomers;

  /// Delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and all their utang records?'**
  String confirmDeleteCustomer(String name);

  /// Delete snackbar
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String customerDeleted(String name);

  /// Warning shown in delete dialog when customer still has an outstanding balance
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance: {amount}'**
  String outstandingBalanceWarning(String amount);

  /// Empty ledger state
  ///
  /// In en, this message translates to:
  /// **'No utang or bayad yet'**
  String get noEntriesYet;

  /// Soft, non-blocking suggestion shown when a new customer name matches an existing one
  ///
  /// In en, this message translates to:
  /// **'You already have a customer named \"{name}\". Consider a different nickname, or add a clue to tell them apart (e.g. \"Kuya Jun\", \"Jun tindera\").'**
  String duplicateNameHint(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
