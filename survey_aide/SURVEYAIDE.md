# SurveyAide

**All-in-one survey fee calculator + survey tools for Philippine geodetic engineers.**

## Goal

Replace the current fragmented workflow (QGIS plugin for survey computation + Kotlin app + separate fee calculator spreadsheet) with a single offline-first Flutter mobile app that handles fee computation, survey data entry, computation, and document generation.

---

## Current Features (v1.0)

### Tab 1 — Calculator (GE Tariff Fee)
- Fee computation for engineering & geodetic services based on regional rate table (CARAGA / ACCRA)
- 4 sub-tabs: Home, Search, Payment, Schedule
- Service categories browsable with pin/favorites support
- Per-service field inputs with auto-compute
- Client name/location capture per quote
- Payment tracking with installment scheduling (partial payment, due dates)
- Export: copy to clipboard, share, image, PDF
- Custom rate overrides per service code
- Import/export rate overrides as JSON
- Dark mode support with system-follow option

### Tab 2 — Tools (12 survey tools)
*All tools are placeholders with Coming Soon badges — math engine not yet ported.*

- Point Entry (geographic/grid/bearing-distance input)
- Coordinate Transform (WGS84 ↔ PRS92, UTM ↔ PTM)
- Zone Detection (auto PRS92/UTM zone)
- Bearing & Distance computation
- Traverse Closure (Compass Rule / Transit Rule)
- Area Computation (Shoelace, DMD)
- Lot Data Computation Sheet (LMB Form GSD-B-11)
- Technical Description (DENR metes-and-bounds)
- Export Documents (TRAVERSE, LDC, DLSD, TRD/TRX)
- Monument Data (BLLM, PSM)
- Field Notes (DENR template)
- GPS / Map Tools

### Tab 3 — Survey Returns (DENR compliance)
*Placeholder with Coming Soon badges.*

- Checklist for DENR documentary requirements
- Survey returns report generation
- Filing history tracking

### UI / UX
- Glassmorphism design (blur + semi-transparent surfaces)
- 3-page horizontal swipe navigation (PageView)
- Dark mode
- Bottom sheets with smooth hide animation when opened
- Glass-styled text fields and bottom nav bars
- Offline-first (SQLite via Drift, SharedPreferences)

---

## Upcoming Features

### Phase 1 — Math Engine Port (QGIS Python → Dart)
- **Coordinate Transform**: 7-parameter Helmert (WGS84 ↔ PRS92), PTM zone math, UTM conversions
- **Traverse Closure**: Latitude/departure, Compass Rule adjustment, precision check (1:10k)
- **Area Computation**: DMD method, coordinate method, cross-multiplication
- **Geodetic Bearing & Distance**: Forward/inverse on ellipsoid

### Phase 2 — Point Entry & Map Tools
- Manual point entry (lat/lon, northing/easting, bearing-distance)
- PRS92 PTM zone auto-detection
- GPS live location capture
- Map canvas point placement (click-to-plot)

### Phase 3 — Document Generation
- DENR-prescribed forms (LDC, DLSD)
- Technical description narrative generator
- TRAVERSE / TRD / TRX export
- Monument recovery sheet

### Phase 4 — Survey Returns Workflow
- Complete DENR checklist with per-item status tracking
- Returns document assembly and filing history

---

## Architecture

| Layer | Tech |
|-------|------|
| Framework | Flutter 3.x |
| State | Riverpod (2.6) |
| Routing | go_router (ShellRoute) |
| Local DB | Drift (SQLite) |
| Reference DB | Pre-populated `reference.db` (regions, provinces, municipalities, barangays) |
| Theming | Custom glassmorphism (light + dark) |
| Build | APK (debug), Kotlin 2.2.10 |

## Related Repos

- **QGIS Plugin**: `SurveyAide` plugin for QGIS 4 (profile-based, map plotting, traverse compute)
- **Native App (deprecating)**: `SurveyAide_old` — native Kotlin app with 96 files, 41 routes, MapLibre GPS

## File Structure

```
lib/
├── core/              # Constants, theme, helpers, AppTheme
├── db/                # Drift database definitions (admin_tables, reference_database)
├── providers/         # Riverpod providers
├── screens/
│   ├── home/          # Calculator page (services, tabs, pinned)
│   ├── search/        # Service search
│   ├── payment/       # Payment list + installment form
│   ├── schedule/      # Calendar + appointments
│   ├── tools/         # 12 survey tool cards (placeholders)
│   ├── survey_returns/ # DENR checklist + reports (placeholders)
│   ├── settings/      # Profile, rate editor, theme
│   ├── setup/         # First-launch onboarding
│   └── quote/         # Quote sheet
├── widgets/           # Shared widgets (glass, press_scale, etc.)
└── services/          # Computation, export, storage
```
