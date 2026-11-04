# Dhuwitku

Personal finance tracker for Android, built for recording small daily expenses fast.
Offline-first, no account needed. UI in Indonesian, amounts in Rupiah.

> *Catat uangmu dalam hitungan detik, pahami keuanganmu sekilas.*

## Features

- **Quick add** (+ button): Expense/Income toggle, big amount display with a built-in keypad
  (`000` key, quick amounts 15.000 / 25.000 / 50.000 / 100.000), category grid, optional
  date, payment method and note. Three taps: amount → category → Simpan.
- **Dashboard**: total balance, this month's income/expenses, remaining monthly budget,
  quick actions, budget warnings, 6-month income vs expense chart, latest 5 transactions.
- **Transactions**: grouped by day with daily totals, search, filter by type / category /
  date range, newest/oldest sort, details, edit, delete (with confirmation; swipe left too).
- **Categories**: 11 default expense + 6 income categories; create/edit/delete with icon
  and color pickers. Deleting a used category moves its transactions to a category you pick.
- **Budgets**: overall monthly budget and per-category limits with progress bars and
  warnings at 75%, 90% and over 100% (also shown right after saving an expense).
  A budget applies from its month onward until changed.
- **Statistics**: daily / weekly / monthly / yearly views, spending trend, category donut,
  income vs expense, 12-month trend, and rule-based insights (no AI, no network).
- **Settings**: light/dark/system theme, currency symbol, CSV export, database backup and
  restore, clearly labeled demo data (removable in one tap), clear all data, app version.

## Tech

Flutter 3.44 · Dart 3.12 · Material 3 · Riverpod 3 · Drift (SQLite) · fl_chart · intl ·
shared_preferences · file_picker.

## Project structure

```
lib/
  main.dart                 # bootstrap: locale, prefs, ProviderScope
  app/                      # MaterialApp, routes, bottom-nav shell, theme
  core/
    database/               # Drift tables, migrations, seeding, DB provider
    constants/ utils/ widgets/
  features/<feature>/
    data/                   # repositories (database access)
    domain/                 # models + pure calculations (unit tested)
    presentation/           # screens, widgets, Riverpod providers
```

Features: `dashboard`, `transactions`, `categories`, `budgets`, `statistics`, `settings`.

All screens derive their numbers from Drift `watch()` streams, so any add / edit / delete
updates the dashboard, history, budgets and statistics at once.

## Data rules

- Amounts are stored as whole Rupiah in `INTEGER` columns (no floating point).
- `CHECK` constraints: amount > 0, type in (`expense`, `income`), valid month/year.
- Foreign keys are on. `transactions.category_id` is `RESTRICT`; `budgets.category_id` is
  `CASCADE`. Category names are unique per type.
- Schema version lives in `AppDatabase.currentSchemaVersion`; add upgrade steps in
  `migration.onUpgrade`. Restore rejects backups from a newer schema.
- Theme is kept in shared_preferences; currency is in the `app_settings` table (so it
  travels with backups).

## Development

```sh
flutter pub get
dart run build_runner build      # regenerate lib/core/database/app_database.g.dart
flutter analyze
flutter test
flutter run
```

## Release build

```sh
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```

To sign with your own key, create `android/key.properties` (git-ignored):

```
storeFile=/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Without it, release builds are signed with the debug key — fine for installing on your
own phone, not for the Play Store.
