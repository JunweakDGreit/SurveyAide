# gep_fee_calculator

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Launching an Android emulator

There are three simple ways to start an Android emulator for development:

- From VS Code: use the **Flutter** extension and run `Flutter: Launch Emulator`.

- From a Unix-like shell (WSL / Git Bash / macOS / Linux) run the provided script:

```bash
./run_emulator.sh
```

- From Windows PowerShell run the PowerShell launcher:

```powershell
./run_emulator.ps1
# or explicitly: pwsh ./run_emulator.ps1
```

Both scripts default to an AVD name of `medium_phone`. If your AVD has a different name, pass it as an argument or edit the script.

Quick commands
- Show available emulators:

```bash
flutter emulators
```

- Launch an emulator by id:

```bash
flutter emulators --launch <emulator-id>
```

- Run the app on the currently selected device/emulator:

```bash
flutter run
# or target a specific device
flutter run -d <device-id>
```

PowerShell usage examples

```powershell
# run default launcher (uses medium_phone by default)
./run_emulator.ps1

# pass a different AVD name
./run_emulator.ps1 -AVD_NAME Pixel_6
```

Bash / WSL usage examples

```bash
# run default launcher
./run_emulator.sh

# pass a different AVD name
AVD_NAME=Pixel_6 ./run_emulator.sh
```

VS Code
- Install the Flutter extension and use `Flutter: Launch Emulator` from the Command Palette. Select the emulator, then press `F5` to run the app in debug mode.

Troubleshooting
- If `flutter emulators` shows no emulators, open Android Studio > AVD Manager and create one.
- If the emulator doesn't appear as a connected device after launching, run `flutter doctor` and follow any setup instructions for Android SDK / platform tools.
- The asset `assets/database/reference.db` contains administrative region records used by the app; if you changed region files, verify the keys in `assets/services.json` match available regions.
