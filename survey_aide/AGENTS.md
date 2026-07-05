# AGENTS.md — survey_aide

Flutter 3.x app for Philippine geodetic engineers. Offline-first fee calculator + survey computation tool.

See `SURVEYAIDE.md` for detailed feature docs and `PLAN.md` for pending implementations.

## Setup

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter analyze
```

See `setup.ps1` for the full provisioning sequence.

## Commands

| Command | Purpose |
|---|---|
| `flutter run` | Run on connected device/emulator |
| `flutter run -d <id>` | Target specific device |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate Drift `.g.dart` files after table changes |
| `flutter analyze` | Lint check (`flutter_lints`, see `analysis_options.yaml`) |
| `flutter test` | Run tests (only 1 smoke test exists) |

Emulator scripts: `./run_emulator.ps1` (Windows) or `./run_emulator.sh` (Unix). Defaults to AVD `Pixel_6`.

## Architecture

- **State**: Riverpod 2.6 — 15 providers in `lib/providers/`
- **Routing**: go_router with `ShellRoute` — tabs for Calculator (`/`), Search (`/search`), Payment (`/payment`), Schedule (`/schedule`), plus `/setup` redirect before onboarding complete
- **DB**: Drift (SQLite) — 10 tables in `lib/db/tables.dart` (Quotes, QuoteItems, RateOverrides, Payments, Appointments, ServiceCategories, Services, ServiceFields, ServiceRates, RateLabels). Generated code in `*.g.dart` files. Seed data (services + rates) read from `assets/services.json` once on DB creation/upgrade. **Schema version: 7**.
- **Reference DB**: `assets/database/reference.db` — pre-populated admin regions/provinces/municipalities/barangays (tables in `lib/db/admin_tables.dart` → `lib/db/reference_database.g.dart`). Copied to app docs on first launch.
- **Storage**: Singleton `StorageService` (`lib/services/storage_service.dart`) wraps both Drift and SharedPreferences. App DB via `appDatabaseProvider`.
- **Entrypoint**: `lib/main.dart` — calls `StorageService.init()` then `runApp(ProviderScope(child: App()))`
- **Domain code**: `computation_service.dart` (fee calc by service code A.1–D.5), `traverse_service.dart` (traverse/area/DMD/Compass Rule/Transit Rule), `zone_service.dart` (PTM zone 1–5, UTM detection), `export_service.dart` (PDF/image export)
- **Rates**: DB-driven — `ServiceRates` table joined on selected region code. Default rates seeded from `assets/services.json`. User overrides stored in `RateOverrides` table.
- **Region selection**: User picks region from `reference.db` `Regions` table during setup. Stored as `gep_admin_region` in SharedPrefs. No hardcoded region enum.
- **Theming**: 6 presets (Classic, Catppuccin, Rosé Pine, Dracula, Nord, Tokyo Night) with light/dark, defined in `lib/core/theme_presets.dart`.

## Git remotes

| Remote | URL | Purpose |
|---|---|---|
| `origin` | `https://github.com/JunweakDGreit/SurveyAide.git` | Push/commit destination |
| `enrd` | `https://github.com/JunweakDGreit/ENRD_Database.git` | Upstream (do not push) |

**Always push to `origin`**: `git push origin main`

## Screen structure

4-page app via horizontal PageView swipe in `home_screen.dart`:

0. **Dashboard** (Page 0): Stat cards (services, income, expenses, net, schedules) + insights
1. **Calculator** (Page 1): ShellRoute child — 4 bottom-nav tabs: Home, Search, Payment, Schedule
2. **Tools** (Page 2): Traverse computation, coordinate tools (with own Home/History sub-tabs)
3. **Survey Returns** (Page 3): DENR checklist — **Easter Egg** (hidden by default, unlocked via Settings → About → 10-tap card, confetti burst animation)

## Codegen requirements

After editing `lib/db/tables.dart`, `lib/db/app_database.dart`, or `lib/db/admin_tables.dart`, run:

```
dart run build_runner build --delete-conflicting-outputs
```

Commit all `.g.dart` files alongside the source changes.

## Notable

- Light transparency design: `glassDecoration()`, `glassInputDecoration()`, `glassBackdrop()` in `lib/core/constants.dart` — subtle translucent overlays instead of heavy glassmorphism
- SharedPrefs persistence keys: `gep_admin_region`, `gep_swipe_hint_shown`, `gep_tools_tab`, `gep_traverse_history`
- **Provider count**: 20+ providers (including business, invoice, dashboard, expense, layout)
- **Push reminder**: always `git push origin main` — never push to `enrd`
- Only 1 test (`test/widget_test.dart`)
- DB file: `ge_tariff.sqlite` in app documents directory
