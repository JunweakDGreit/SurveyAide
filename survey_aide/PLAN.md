# PLAN.md — Pending Implementations

## 1. Scroll-aware navbar hiding
- `uiprovider.dart` — Add `navBarScrollHiddenProvider`
- `home_screen.dart` — Combined `_updateNavBar()` with dual listeners (modal + scroll)
- `calculator_view.dart` — `NotificationListener` scroll detection + `AnimatedPadding` (90px visible / 16px hidden)

## 2. Expense Calculator feature
- `expense_provider.dart` — NEW — `ExpenseEntry` class + `expenseProvider`
- `expense_form.dart` — NEW — Dialog with label, type toggle (value/percentage), value input, base dropdown (total/net)
- `payment_view.dart` — Watch expenses, add Expense section after Payment, add Net Income display, rename "Installment" → "Payment"
- `installment_form.dart` — Rename title "Installment" → "Payment"

## 3. Navbar preset colors + glass
- `bottom_nav_bar.dart` — Watch `themeProvider`, pass `background: presetColors.cardColor` to `glassBackdrop`
- `tools_page.dart` — Same glass fix
- `survey_returns_page.dart` — Same glass fix

## 4. FAB hidden behind navbar
- `schedule_view.dart` — Add `Padding(padding: EdgeInsets.only(bottom: 80))` around FAB

## 5. Settings persistence (done, needs verification)
- `setup_provider.dart` — `_load()` → `reloadFromStorage()` (public)
- `settings_sheet.dart` — `reloadFromStorage()` called in `whenComplete`

## 6. Payment tab enhancements
- `payment_view.dart` — Add actual monetary value display next to percentage in payment entries
- `payment_view.dart` — Add total payment amount and total expense summary in the card
- `expense_provider.dart` — Ensure total expense calculation aggregates all entries
- Update payment card UI to show: total collected, total expense, net (collected - expense)

## 7. Dashboard screen (Page 0 — landing page)
- `dashboard_view.dart` — NEW — Glassmorphism dashboard with stat cards:
  - **Services Done** — total `QuoteEntry` count
  - **Total Income** — sum of all paid `Installment.amount()` where `paid == true`
  - **Total Expense** — sum of all `ExpenseEntry.computeAmount()`
  - **Net Income** — Total Income − Total Expense
  - **Upcoming Schedules** — count of `Appointment` where `date >= today`
- `dashboard_provider.dart` — NEW — Computed aggregate provider watching `quoteProvider`, `paymentProvider`, `expenseProvider`, `appointmentProvider`; exposes `DashboardStats` record
- `home_screen.dart` — Insert `DashboardView` as **Page 0** in the `PageView` (before existing Calculator at Page 1); shift Tools → Page 2, Returns → Page 3
- `dashboard_view.dart` — **Insights/suggestions widget** below stat cards:
  - "You have X unpaid receivables" (sum of unpaid installments)
  - "Most-used service: {code}" (mode of `QuoteEntry.code`)
  - "X appointments this week" (appointments in next 7 days)
  - "Top client by revenue: {client}" (client with highest total paid)
- No time-based charts, no date fields added to models
- No new DB tables or migrations required
