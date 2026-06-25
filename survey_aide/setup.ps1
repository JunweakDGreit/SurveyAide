# GEP Fee Calculator — Flutter Setup
Write-Host "=== GEP Fee Calculator Setup ===" -ForegroundColor Cyan

Set-Location -LiteralPath "C:\Users\junag\Github\survey_aide"

# 1. Generate platform folders (android, ios, etc.)
Write-Host "[1/4] Creating platform folders..." -ForegroundColor Yellow
flutter create --project-name survey_aide .

# 2. Install dependencies
Write-Host "[2/4] Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Generate Drift database code (app_database.g.dart)
Write-Host "[3/4] Generating Drift code..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

# 4. Verify compilation
Write-Host "[4/4] Running analyze..." -ForegroundColor Yellow
flutter analyze

Write-Host "=== Setup complete! Run 'flutter run' to start. ===" -ForegroundColor Green
