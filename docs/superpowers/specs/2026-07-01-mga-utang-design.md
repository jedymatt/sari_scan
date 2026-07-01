# Mga Utang — Customer Credit Ledger (Design)

**Date:** 2026-07-01
**Status:** Approved design, pending implementation plan

## Overview

"Mga Utang" (debts) is the sari-sari store *utang/listahan* feature: customers buy on
credit and pay later, traditionally tracked in a paper notebook. This feature digitizes
that notebook as a **per-customer ledger** with a running balance, debts (*utang*), and
partial payments (*bayad*).

The home page already contains a disabled placeholder card ("Mga Utang" / "Coming Soon").
This feature makes that card live.

## Goals

- Track per-customer running balances (total owed minus total paid).
- Record debts and partial payments quickly, notebook-style (amount + optional note).
- See who owes what, and the total amount outstanding across all customers.
- Keep or hide customer records via archive; delete with confirmation when desired.

## Non-Goals (YAGNI)

- No itemized carts or line-items per debt. A debt is a single amount + optional note.
- No linking debts to scanned products or the product catalog.
- No SMS/notification reminders (phone is stored for future use only).
- No customer photos, addresses, or credit limits.
- No multi-store / multi-user support.

## Decisions (from brainstorming)

- **Core model:** per-customer ledger with running balance (not a flat log, not product-tied).
- **Debt entry:** peso amount + optional freeform note. Payments recorded the same way.
- **Customer fields:** name (required) + optional phone.
- **Payments:** partial payments supported; balance = Σ debts − Σ payments.
- **Delete:** always allowed, behind a confirmation dialog (warns if balance outstanding).
- **Archive:** hides the customer from the default list but keeps all records; restorable.
  Recording a new utang on an archived customer auto-unarchives them.

## Data Model (Drift)

Two new tables. `AppDatabase.schemaVersion` bumps **1 → 2**.

```dart
enum UtangType { debt, payment }

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class UtangEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get type => textEnum<UtangType>()();   // debt | payment
  RealColumn get amount => real()();                 // always positive
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Modeling choice:** debts and payments live in one table distinguished by a `type` enum
with a positive `amount` (rather than signed amounts or two separate tables). This gives a
single chronological history and avoids sign-related bugs in queries and UI.

### Migration (critical)

The app currently defines **no `MigrationStrategy`**, which is safe only for a single-version
schema. Adding tables requires an explicit strategy so existing users keep their `Products`:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.createTable(customers);
      await m.createTable(utangEntries);
    }
  },
);
```

After editing `lib/database.dart`, regenerate with `dart run build_runner build`.

## Models (`lib/models.dart`)

Add `Customer` and `UtangEntry` model classes following the existing `Product` style
(`toMap`/`fromMap`/`copyWith`/`==`/`hashCode`). Add a lightweight `CustomerWithBalance`
class (holds a `Customer` plus a computed `balance`) that the list query returns and the
list UI renders.

## API Layer (`lib/db.dart`)

Follows the existing top-level-function + singleton pattern. New functions:

- `queryCustomers({bool archived = false})` → customers matching archived flag, each with a
  **running balance** computed via a single SQL aggregate join (not one query per customer).
- `insertCustomer(Customer)` / `updateCustomer(Customer)`
- `deleteCustomer(int id)` → deletes the customer and all their entries.
- `setCustomerArchived(int id, bool archived)`
- `queryEntries(int customerId)` → chronological ledger (newest first).
- `insertEntry({int customerId, UtangType type, double amount, String? note})` → also
  clears the customer's `archived` flag when a `debt` is added to an archived customer.
- `deleteEntry(int id)`
- `totalOutstanding()` → sum of balances across active customers, for the list header and
  (optionally) the home card subtitle.

## Screens

All screens are `StatefulWidget` pages using the existing `_navigateAndRefresh` reload
pattern (reload data after returning from a pushed route).

### 1. MgaUtangPage (customer list)

- App bar title "Mga Utang".
- Header: **total outstanding** across active customers.
- **Active / Archived filter** (segmented control or toggle).
- Each row: name, optional phone, current balance (emphasized red when owing, muted when
  settled/zero). Tapping opens the ledger.
- Search by name (in-memory filter, like `ManageProductsPage`).
- FAB: add a new customer.
- Empty state when no customers.

### 2. CustomerLedgerPage (customer detail)

- Customer name + phone; large current balance.
- Chronological list of entries: utang shown as an increase, bayad as a decrease, each with
  amount, optional note, and date.
- Two primary actions: **Add Utang** and **Add Bayad**.
- Overflow menu: edit customer, archive/unarchive, delete (with confirmation).
- Deleting an individual entry recomputes the balance.

### 3. Add/Edit Customer form

- Fields: name (required), phone (optional).
- Reused for create and edit.

### 4. Add Entry (bottom sheet)

- Fields: amount (required, positive) + optional note.
- Reused for both utang and bayad; the caller passes the `UtangType`.
- Amount validation: must be a positive number.

## Home Page Wiring

In `lib/pages/home_page.dart`, the third `_ActionCard`:

- Remove `disabled: true` and the `comingSoon` subtitle.
- Set a real subtitle (e.g. a localized "Track customer debts").
- `onTap` navigates to `MgaUtangPage` via `_navigateAndRefresh`.

## Internationalization

Add localized strings for all new labels to **both** `lib/l10n/app_en.arb` and
`lib/l10n/app_ceb.arb`, then regenerate. New keys include (names indicative): customer,
customers, addCustomer, editCustomer, customerName, phone, addUtang, addBayad, balance,
totalOutstanding, active, archived, archive, unarchive, deleteCustomer,
deleteCustomerConfirm, amount, note, settled, noCustomers.

## Error Handling & Edge Cases

- Amount input rejects non-positive / non-numeric values with inline validation.
- Deleting a customer with an outstanding balance is allowed but the confirmation dialog
  states the outstanding amount.
- Balance for a customer with no entries is 0 (shown as settled).
- Payments may exceed debts (overpayment) → negative balance is allowed and displayed
  (store owes/credit); acceptable for MVP, no special handling.
- Adding a debt to an archived customer auto-unarchives them.

## Testing Focus

Highest to lowest priority:

1. **Migration v1 → v2** preserves existing `Products` data and creates the new tables.
2. **Balance computation:** debts − payments, partial payments, settled = 0, overpayment.
3. **Archive behavior:** archived customers excluded from active list; auto-unarchive on new
   debt; restore.
4. **Cascade delete:** deleting a customer removes their entries.
5. Widget test for the add-entry validation (positive amount required).

## Affected / New Files

- `lib/database.dart` — new tables, `schemaVersion` 2, `MigrationStrategy`.
- `lib/database.g.dart` — regenerated.
- `lib/models.dart` — `Customer`, `UtangEntry`, `UtangType`, balance carrier.
- `lib/db.dart` — new query/mutation functions.
- `lib/pages/mga_utang/mga_utang_page.dart` — customer list (new).
- `lib/pages/mga_utang/customer_ledger_page.dart` — ledger detail (new).
- `lib/pages/mga_utang/edit_customer_page.dart` — add/edit customer (new).
- `lib/pages/mga_utang/add_entry_sheet.dart` — add utang/bayad bottom sheet (new).
- `lib/pages/home_page.dart` — enable and wire the Mga Utang card.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ceb.arb` — new strings.
- `test/` — migration, balance, and validation tests.
