# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sari Scan is a Flutter **Android-only** app for barcode-based price scanning in sari-sari stores (small retail shops in the Philippines). It scans product barcodes to look up prices and allows registering new products with prices.

**Current Status:** Core features implemented (scan, register, manage products).

**Planned Features:**
- Export and import functionality for backup and restore
- Standalone static website for managing products (uses import/export files, no backend)

**Limitations:** Relies on barcodes; not suitable for products without barcodes (e.g., eggs, onions, garlic).

## Commands

```bash
# Install dependencies
flutter pub get

# Generate code (required after modifying database schema in lib/database.dart)
dart run build_runner build

# Watch for changes and regenerate code automatically
dart run build_runner watch

# Run on connected device/emulator
flutter run

# Build release APK (uses signing config in android/key.properties)
flutter build apk --release

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Static analysis
flutter analyze

# Format code
dart format lib/
```

## Architecture

**No state management library** — uses StatefulWidget with setState directly. No dependency injection or repository pattern.

### Data Flow
Pages call database functions directly from `lib/db.dart`. The database layer exposes top-level async functions (`queryProducts()`, `insertProduct()`, `updateProduct()`, `deleteProduct()`) that use a singleton Drift database instance. StatefulWidget pages reload data after navigation (e.g., HomePage refreshes product count after returning from other pages).

### Key Files
- `lib/main.dart` — App entry point, MaterialApp with Material 3, theme and locale management
- `lib/models.dart` — `Product` model (id, name, price, barcode) with Map/JSON serialization
- `lib/database.dart` — Drift table definitions (Products table schema)
- `lib/database.g.dart` — Generated Drift code (do not edit manually)
- `lib/db.dart` — Database API layer exposing top-level functions; uses singleton Drift database
- `lib/core/currency.dart` — Philippine Peso formatter (`phpFormat`)
- `lib/l10n/` — Generated internationalization files (English and Cebuano)
- `lib/pages/camera_page.dart` — Barcode scanning via `mobile_scanner`; shows product price or "not found" inline as overlay
- `lib/pages/product_management/` — CRUD screens for products
  - `manage_products_page.dart` — List view with local search (filters by name/barcode in-memory)
  - `register_product_page.dart` — Add new product with barcode pre-filled
  - `edit_product_page.dart` — Edit existing product details
- `lib/components/` — Reusable UI components

### Theme and Locale Management
Theme mode (system/light/dark) and locale (English/Cebuano) are managed in `MyApp` state and persisted via `shared_preferences`. Pages access them through static methods:
- `MyApp.setThemeMode(context, mode)` and `MyApp.themeMode(context)`
- `MyApp.setLocale(context, locale)` and `MyApp.locale(context)`
- All methods use `findAncestorStateOfType` to access `_MyAppState`
- Localized strings are accessed via `AppLocalizations.of(context)`

### Navigation
Imperative navigation with `Navigator.push()`. No named routes.

### Barcode Scanning Flow
1. `CameraPage` uses `mobile_scanner` with StreamBuilder to listen for barcode scans
2. Queries products from database via FutureBuilder
3. If barcode matches existing product, displays price overlay with edit option
4. If no match, shows "Product not found" with button to navigate to `RegisterProductPage` (pre-fills barcode)
5. Camera is stopped during navigation and restarted on return

### Database Schema
Uses **Drift** for type-safe database operations. SQLite database `sari_scan.db`, version 1:

**Drift table definition** (`lib/database.dart`):
```dart
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get barcode => text()();
}
```

**Database API** (`lib/db.dart`): Top-level functions use singleton `AppDatabase` instance. After modifying the schema in `lib/database.dart`, run `dart run build_runner build` to regenerate `lib/database.g.dart`.

### Currency
Uses `intl` package — `phpFormat` global in `lib/core/currency.dart` for Philippine Peso (₱) formatting.
