# Devlog

## 2026-07-21

- Started the `Clocktower Reactor` project folder.
- Chosen direction: mobile pseudo-3D 2D Godot project.
- Confirmed local machine already has Flutter, Dart, and Git.
- Confirmed Godot is not currently available from the local command line.
- Checked the official Godot download page: Godot 4.7 stable is listed as the current stable release, dated 2026-06-18.
- Created the first Godot project skeleton with a main scene, simulation layer, pseudo-3D cylinder projection, renderer, HUD, and placeholder icon.
- Documented MVP scope and architecture before feature work expands.
- Downloaded Godot 4.7 stable Standard Windows x86_64 portable editor into `tools/godot-4.7-stable/`.
- Verified downloaded editor zip SHA256: `02A5312236F4E0209C78BCB2F52135B1963E6B8888C873C9CEE81459E60BCD71`.
- Extracted Godot executable and console executable.
- Ran Godot 4.7 headless project check. First pass found strict GDScript typing issues.
- Fixed GDScript typing issues in simulation and presentation layers.
- Re-ran Godot headless project check successfully with no script errors.

## Step Log Format

Every meaningful project action should be added here with:

- date
- what changed
- why it changed
- verification result
