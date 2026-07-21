# Installation Notes

## Local Status

Checked on 2026-07-21:

- Flutter: installed
- Dart: installed
- Git: installed
- Godot command: not found
- Package managers checked from command line: no usable `winget`, `choco`, or `scoop` command detected

## Target Godot Version

Use Godot 4.7 stable Standard for Windows x86_64.

Official source checked:

- Godot download archive page lists Godot 4.7 stable, dated 2026-06-18.
- Windows x86_64 Standard build is listed on the same official page.
- Export templates are listed separately and are needed later for Android/iOS builds.

## Proposed Local Tool Layout

Download portable tools into:

`tools/godot-4.7-stable/`

Current files:

- `Godot_v4.7-stable_win64.exe.zip`
- `Godot_v4.7-stable_win64.exe`
- `Godot_v4.7-stable_win64_console.exe`

Verified SHA256 for the editor zip:

`02A5312236F4E0209C78BCB2F52135B1963E6B8888C873C9CEE81459E60BCD71`

This matches the published 64-bit Windows checksum from the package verification record found during setup.

## Run Locally

For normal use, double-click:

`Open Clocktower Reactor.bat`

This opens the project directly in the Godot editor.

From the project folder:

`tools\godot-4.7-stable\Godot_v4.7-stable_win64.exe --path .`

For command-line verification:

`tools\godot-4.7-stable\Godot_v4.7-stable_win64_console.exe --headless --path . --quit`

## Android Export Later

Android export will also need:

- JDK
- Android Studio or Android command-line tools
- Android SDK platform tools
- Godot Android export templates
- signing key for release builds

For the MVP, these are not required until the desktop prototype is playable.
