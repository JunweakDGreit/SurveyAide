param(
  [string]$AVD_NAME = "Pixel 6"
)

# Check for flutter in PATH
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter CLI not found in PATH. Install Flutter and ensure 'flutter' is available."
  exit 1
}

# List available emulators
$emulators = flutter emulators --machine | ConvertFrom-Json | ForEach-Object { $_.name }
if (-not ($emulators -contains $AVD_NAME)) {
  Write-Host "AVD '$AVD_NAME' not found. Available emulators:" -ForegroundColor Yellow
  flutter emulators
  Write-Host "Create one with: flutter emulators --create --name $AVD_NAME --device-id pixel" -ForegroundColor Cyan
  exit 1
}

# Launch emulator
Write-Host "Launching emulator $AVD_NAME..."
Start-Process -NoNewWindow -FilePath flutter -ArgumentList "emulators --launch $AVD_NAME"
Write-Host "Emulator launch command issued."