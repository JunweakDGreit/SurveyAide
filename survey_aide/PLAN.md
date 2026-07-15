# PLAN.md — Pending Implementations

## ✅ Completed

| # | Item | Status |
|---|------|--------|
| 1 | Scroll-aware navbar hiding | Done — `navBarScrollHiddenProvider` in `uiprovider.dart`, `NotificationListener` + `AnimatedPadding` in `calculator_view.dart` |
| 2 | Expense Calculator | Done — `ExpenseEntry` + `expenseProvider` in `expense_provider.dart`, `expense_form.dart` wired into `payment_view.dart` |
| 3 | Navbar preset colors + glass | Done — `bottom_nav_bar.dart` watches `themeProvider`, passes `presetColors.cardColor` to `glassBackdrop` |
| 4 | FAB hidden behind navbar | Done — `schedule_view.dart` wraps FAB in `EdgeInsets.only(bottom: 80)` |
| 5 | Settings persistence | Done — `reloadFromStorage()` in `setup_provider.dart`, called in `settings_sheet.dart` |
| 6 | Payment tab enhancements | Done — monetary values alongside percentages, total/net/expense summary in `payment_view.dart` |
| 7 | Dashboard screen (Page 0) | Done — `DashboardView` with stat cards + insights in `dashboard_view.dart`, `DashboardStats` in `dashboard_provider.dart` |

## ⏳ Remaining Work

### A. Coordinate Transform — standalone UI entry point
- Transform is currently only accessible via the traverse dialog (N/E fallback)
- Add a direct "Transform" button or nav tab in Tools page for quick coordinate entry (no traverse needed)

### B. Survey Returns (DENR compliance)
- `survey_returns_page.dart` has 3-tab shell (Checklist / Reports / History)
- Most checklist items are `_Status.notStarted` placeholders
- Need: per-item status tracking, DENR documentary requirements, filing history storage

### C. Document Generation
- LDC (Lot Data Computation) sheet export
- DLSD XML export (one placeholder exists)
- Technical Description narrative generator (metes and bounds)
- TRAVERSE / TRD / TRX export
- Monument Recovery Sheet

### D. Point Entry & Map Tools (Phase 2)
- Manual point entry (lat/lon, northing/easting, bearing-distance)
- PRS92 PTM zone auto-detection from coordinates
- GPS live location capture
- Map canvas point placement (click-to-plot)
