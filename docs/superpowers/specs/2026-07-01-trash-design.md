# Trash (replaces Archive) — Design

**Date:** 2026-07-01
**Status:** Approved design, pending implementation plan
**Context:** Iterates the Mga Utang feature on branch `feature/mga-utang` / PR #15 (unmerged).

## Overview

Replace the customer **Archive** concept with **Trash**. Moving a customer to Trash
soft-deletes them (hidden from the Active list); they can be **restored**, and are
**permanently purged 30 days** after being trashed. Trashed customers are **view-only** —
no new utang/bayad until restored. The hard "Delete Customer" action on active customers is
removed; all deletion now routes through Trash (or the 30-day auto-purge).

## Decisions

- **View-only trashed customers.** A trashed customer's ledger hides Add Utang / Add Bayad.
  To transact again, Restore first.
- **Trash controls:** Restore, Delete permanently (now), and a "Deletes in N days" countdown.
- **No client scheduler:** "auto-delete after 30 days" is enforced by purging expired trash
  when the app runs (startup + opening the Trash tab).
- **No hard delete on active customers:** the primary destructive action on an active
  customer is Move to Trash (reversible). Permanent deletion happens only from Trash or via
  auto-purge.
- **Move to Trash shows a snackbar with UNDO** (reversible action, no blocking dialog).
- **Retention: 30 days**, expressed as a single named constant.

## Schema

Because v2 (which introduced the `customers` table) is **unreleased** — only v1 exists on
`master` — v2 is redefined in place rather than adding a v3 migration.

- Rename `Customer.archivedAt` → **`deletedAt`** (nullable `DateTime`).
- Rename getter `isArchived` → **`isTrashed`** (`deletedAt != null`).
- Drift column `archived_at` → **`deleted_at`** in the `Customers` table.
- `Customer.copyWith` flag `clearArchivedAt` → **`clearDeletedAt`**.
- The v1→v2 migration and its test are updated to create/expect `deleted_at`.

```dart
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // null = active, set = in trash
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

## DB API (`lib/db.dart`)

- `queryCustomers({bool trashed = false})` — filter on `deletedAt` (active = null,
  trashed = non-null). Balance still via `balanceOf` (unchanged).
- `setCustomerTrashed(int id, bool trashed)` — sets `deletedAt = DateTime.now()` when
  trashing, `null` when restoring. (Replaces `setCustomerArchived`.)
- `insertEntry(...)` — **remove** the auto-unarchive block; trashed customers are view-only,
  so entries are never added to them.
- `deleteCustomer(int id)` — unchanged; the permanent hard-delete (customer + entries in a
  transaction). Now reached only from Trash's "Delete permanently".
- `totalOutstanding()` — unchanged (sums positive balances of active customers).
- **New** `purgeExpiredTrash({Duration retention = const Duration(days: 30)})` — computes
  `cutoff = DateTime.now().subtract(retention)`, finds customers with
  `deletedAt < cutoff`, and deletes them and their entries in a transaction. Returns the
  number of customers purged.

The 30-day retention lives in one place, e.g. `const trashRetention = Duration(days: 30);`
in `lib/core/` (or as the default parameter). Both the purge and the countdown use it.

## Purge trigger

`purgeExpiredTrash()` is invoked:
1. **On app startup** — awaited in `main()` after `WidgetsFlutterBinding.ensureInitialized()`
   and before `runApp`. Data volumes are tiny; this is fast.
2. **When the Trash tab is opened** — the list calls it before loading trashed customers, so
   the shown list and countdowns are current within a session.

## UI

### Customer list (`lib/pages/mga_utang/mga_utang_page.dart`)
- SegmentedButton filter labels become **Active / Trash** (`_showArchived` → `_showTrash`).
- Selecting **Trash**: call `purgeExpiredTrash()`, then `queryCustomers(trashed: true)`.
- Trash rows show **"Deletes in N days"** (computed, see below) in place of the balance
  emphasis; tapping still opens the (view-only) ledger.
- Empty states: Active → existing "no customers"; Trash → **"Trash is empty."**

### Customer ledger (`lib/pages/mga_utang/customer_ledger_page.dart`)
- **Active** customer → overflow menu: **Edit**, **Move to Trash**.
  - Move to Trash: `setCustomerTrashed(id, true)`, pop, and show a root-messenger snackbar
    **"Moved to trash"** with an **UNDO** action that calls `setCustomerTrashed(id, false)`.
- **Trashed** customer → **view-only**: Add Utang / Add Bayad hidden; a banner
  a banner reusing `deletesInDays` (e.g. "Deletes in N days"); overflow menu: **Restore**,
  **Delete permanently**.
  - Restore: `setCustomerTrashed(id, false)`, reload.
  - Delete permanently: confirmation `AlertDialog` (reusing `confirmDeleteCustomer` and, when
    `balance > 0`, `outstandingBalanceWarning`), then `deleteCustomer(id)`, pop, snackbar
    "{name} deleted".

### Days-remaining computation
A small pure helper (testable, no widgets):

```dart
int daysUntilPurge(DateTime deletedAt, DateTime now,
    {Duration retention = trashRetention}) {
  final remaining = retention - now.difference(deletedAt);
  return remaining.isNegative ? 0 : remaining.inDays;
}
```

`now` is a required parameter so the function stays pure and testable; UI call sites pass
`DateTime.now()`, tests pass a fixed instant.

## Localization (en + ceb)

- **Repurpose** existing keys' usage: `archived` → Trash filter label "Trash" (rename key to
  `trash`), `archive` → `moveToTrash` ("Move to Trash"), `unarchive` → `restore` ("Restore").
- **Add:** `deletePermanently` ("Delete Permanently"), `movedToTrash` ("Moved to trash"),
  `undo` ("Undo"), `deletesInDays` (plural ICU, "Deletes in {count, plural, ...}" — used by
  both the Trash list rows and the ledger banner), `noTrashedCustomers` ("Trash is empty").
- **Reuse:** `confirmDeleteCustomer`, `outstandingBalanceWarning`, `customerDeleted`,
  `cancel`, `delete`, `active`.
- **Remove** now-unused keys after the rename (`archived`, `archive`, `unarchive`) if not
  otherwise referenced.

## Error handling & edge cases

- `deletedAt` is nullable; countdown/banner only render when `deletedAt != null`.
- A trashed customer opened just before its purge: purge runs on startup/trash-open, not
  while viewing; if it's already past cutoff and the user opens Trash, it disappears on that
  load — acceptable.
- Restoring clears `deletedAt` so the countdown stops.
- `purgeExpiredTrash` deletes entries before customers within a transaction (FK-safe), same
  pattern as `deleteCustomer`.

## Testing

Highest to lowest priority:

1. **`purgeExpiredTrash`**: customer trashed 31 days ago is purged along with its entries;
   trashed 10 days ago survives; active (deletedAt null) untouched. Use injectable `now` or
   set `deletedAt` explicitly in setup.
2. **Migration** v1→v2 updated to create/expect `deleted_at` and still preserve products.
3. **`setCustomerTrashed`** toggles `deletedAt`; `queryCustomers(trashed:)` filters correctly.
4. **Auto-unarchive removed:** adding a debt to a trashed customer does NOT restore them
   (guarded at the UI level by view-only, but verify the db no longer clears `deletedAt`).
5. **`daysUntilPurge`** pure-function: full retention, mid-window, past-cutoff clamps to 0.

## Affected files

- `lib/models.dart` — rename `archivedAt`/`isArchived`/`clearArchivedAt`; add `daysUntilPurge` (or a `core/` helper).
- `lib/database.dart` + `lib/database.g.dart` — column rename, migration; regenerate.
- `lib/db.dart` — rename query param + `setCustomerTrashed`, remove auto-unarchive, add `purgeExpiredTrash`.
- `lib/core/` — `trashRetention` constant (+ possibly `daysUntilPurge`).
- `lib/main.dart` — startup purge call.
- `lib/pages/mga_utang/mga_utang_page.dart` — Active/Trash filter, purge-on-open, countdown, empty state.
- `lib/pages/mga_utang/customer_ledger_page.dart` — move-to-trash / restore / delete-permanently, view-only, banner.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ceb.arb` — string changes; regenerate.
- `test/` — purge tests, migration update, db renames, `daysUntilPurge` test.
