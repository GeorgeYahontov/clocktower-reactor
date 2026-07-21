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
- Started phase 2: converting the scaffold into a touchable first run.
- Added mobile-style touch controls: horizontal drag rotates the tower, lower-screen taps change lanes.
- Added run state: reactor integrity, kill count, victory after the run timer, defeat when integrity reaches zero.
- Added visible shot traces and energy pulse effects so automatic combat is readable.
- Added tutorial/status HUD text for the first prototype run.
- Added `Open Clocktower Reactor.bat` so the project can be opened in the Godot editor by double-clicking instead of typing a command.
- Re-ran Godot 4.7 headless project check successfully after phase 2 changes.
- Opened the project in the visible Godot editor window.
- Started phase 3: first replayable loop.
- Added an `UpgradeCatalog` data layer with six prototype upgrades.
- Added level-up upgrade choices that pause the run until one option is selected.
- Added upgrade effects for fire rate, targeting, integrity repair, energy bonus, rotation speed, and max integrity.
- Added a heavier `bulwark` enemy type that appears after the run has warmed up.
- Added a restart button for victory/defeat states.
- Re-ran Godot 4.7 headless project check successfully after phase 3 changes.
- Started phase 3: first replayable loop.
- Added an `UpgradeCatalog` data layer with six prototype upgrades.
- Added level-up upgrade choices that pause the run until one option is selected.
- Added upgrade effects for fire rate, targeting, integrity repair, energy bonus, rotation speed, and max integrity.
- Added a heavier `bulwark` enemy type that appears after the run has warmed up.
- Added a restart button for victory/defeat states.
- Re-ran Godot 4.7 headless project check successfully after phase 3 changes.

- Moved the active working copy to `D:\Codex\clocktower-reactor` and updated the desktop Godot shortcut to the new path.

- Changed desktop/player movement so `A/D` walk around tower sectors, `W/S` change lanes, and `Q/E` or mouse drag rotate the tower.

- Added emergency reactor vents: timed hazards that must be repaired by standing on their sector/lane before they damage reactor integrity.

- Added stabilizing pulse active ability on `Space` / right mouse button: it damages nearby enemies, repairs nearby vents, shows a pulse effect, and uses cooldown.

- Improved gameplay readability: explained vents/heavy enemies in HUD, added upgrade icons, and redrew the tower with lane rings, sector guides, visible front band, and clearer enemy/vent shapes.

- Added a compact tower radar that shows player position, enemies, vents, lanes, and current camera-facing direction from above.

- Added clear reactor-coil rotation cues: central glowing core, front work-zone highlight, moving surface ticks, and a golden seam marker.

## Step Log Format

Every meaningful project action should be added here with:

- date
- what changed
- why it changed
- verification result
