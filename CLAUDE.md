# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sari Scan is a Flutter **Android-only** app for barcode-based price scanning in sari-sari stores (small retail shops in the Philippines). It scans product barcodes to look up prices and allows registering new products with prices.

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
Pages call database functions directly from `lib/db.dart`. The database layer exposes top-level async functions (`queryProducts()`, `insertProduct()`) that each open their own database connection via `getDbClient()`.

### Key Files
- `lib/main.dart` — App entry point, MaterialApp with Material 3, theme management
- `lib/models.dart` — `Product` model (id, name, price, barcode) with Map/JSON serialization
- `lib/db.dart` — SQLite operations via `sqflite`. Single table: `products`
- `lib/core/currency.dart` — Philippine Peso formatter (`phpFormat`)
- `lib/pages/camera_page.dart` — Barcode scanning via `mobile_scanner`; shows product price or "not found" inline as overlay
- `lib/pages/product_management/` — CRUD screens for products

### Theme Management
Theme mode (system/light/dark) is managed in `MyApp` state and persisted via `shared_preferences`. Pages access it through static methods `MyApp.setThemeMode(context, mode)` and `MyApp.themeMode(context)` which use `findAncestorStateOfType`.

### Navigation
Imperative navigation with `Navigator.push()`. No named routes.

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
