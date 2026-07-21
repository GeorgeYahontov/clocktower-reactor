# Clocktower Reactor

Mobile pseudo-3D arcade roguelite prototype.

The MVP is built around a rotating reactor tower. Internally the game is a small 2D grid:

- `lane`: vertical ring on the tower
- `sector`: angular position around the tower

The presentation layer projects that grid into a pseudo-3D cylinder, so the game can look busy and spatial without needing a heavy 3D pipeline.

## Current Target

- Engine: Godot 4.7 stable, Standard build
- Language: GDScript
- First platform: desktop preview
- Later platform: Android, then iOS if the core loop survives playtesting

## Open The Project

1. Install or run Godot 4.7 stable.
2. Open `project.godot`.
3. Run the `Main` scene.

## Documentation

- `docs/00-devlog.md`: every project step and decision
- `docs/01-mvp-plan.md`: first playable MVP plan
- `docs/02-architecture-macro.md`: high-level structure
- `docs/03-architecture-micro-layers.md`: layer-by-layer implementation architecture
- `docs/04-installation.md`: local tool setup
