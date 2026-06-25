#!/usr/bin/env bash
# Run the Android emulator for a medium‑size phone (default AVD "medium_phone")
# This script assumes the Android SDK is in your PATH (avdmanager, emulator, flutter)

set -e

# Name of the AVD to launch – adjust if your AVD has a different name
AVD_NAME="Pixel_6"

# Check if the AVD exists
if ! flutter emulators | grep -q "$AVD_NAME"; then
  echo "AVD \"$AVD_NAME\" not found. Listing available emulators:"
  flutter emulators
  echo "\nCreate one with: flutter emulators --create --name $AVD_NAME --device-id pixel"
  exit 1
fi

# Launch the emulator in the background
flutter emulators --launch $AVD_NAME &

echo "Emulator $AVD_NAME launched."
