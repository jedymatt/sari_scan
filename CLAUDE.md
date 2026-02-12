# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sari Scan is a Flutter **Android-only** app for barcode-based price scanning in sari-sari stores (small retail shops in the Philippines). It scans product barcodes to look up prices and allows registering new products with prices.

**Current Status:** Core features implemented (scan, register, manage products). Planned features include export/import for backup and "Mga Utang" (credit tracking).

## Commands

```bash
# Install dependencies
flutter pub get

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
Pages call database functions directly from `lib/db.dart`. The database layer exposes top-level async functions (`queryProducts()`, `insertProduct()`, `updateProduct()`, `deleteProduct()`) that each open their own database connection via `getDbClient()`. StatefulWidget pages reload data after navigation (e.g., HomePage refreshes product count after returning from other pages).

### Key Files
- `lib/main.dart` — App entry point, MaterialApp with Material 3, theme management
- `lib/models.dart` — `Product` model (id, name, price, barcode) with Map/JSON serialization
- `lib/db.dart` — SQLite operations via `sqflite`. Single table: `products`
- `lib/core/currency.dart` — Philippine Peso formatter (`phpFormat`)
- `lib/pages/camera_page.dart` — Barcode scanning via `mobile_scanner`; shows product price or "not found" inline as overlay
- `lib/pages/product_management/` — CRUD screens for products
  - `manage_products_page.dart` — List view with local search (filters by name/barcode in-memory)
  - `register_product_page.dart` — Add new product with barcode pre-filled
  - `edit_product_page.dart` — Edit existing product details
- `lib/components/` — Reusable UI components

### Theme Management
Theme mode (system/light/dark) is managed in `MyApp` state and persisted via `shared_preferences`. Pages access it through static methods `MyApp.setThemeMode(context, mode)` and `MyApp.themeMode(context)` which use `findAncestorStateOfType`.

### Navigation
Imperative navigation with `Navigator.push()`. No named routes.

### Barcode Scanning Flow
1. `CameraPage` uses `mobile_scanner` with StreamBuilder to listen for barcode scans
2. Queries products from database via FutureBuilder
3. If barcode matches existing product, displays price overlay with edit option
4. If no match, shows "Product not found" with button to navigate to `RegisterProductPage` (pre-fills barcode)
5. Camera is stopped during navigation and restarted on return

### Database Schema
SQLite database `sari_scan.db`, version 1:
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  price REAL,
  barcode TEXT
)
```

### Currency
Uses `intl` package — `phpFormat` global in `lib/core/currency.dart` for Philippine Peso (₱) formatting.
