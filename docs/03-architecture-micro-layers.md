# Micro Layer Architecture

## Layer 1: Data

Path: `scripts/data`

Owns numbers and rules that designers tweak:

- `GameConfig.gd`: arena size, timers, base stats
- future `UpgradeCatalog.gd`: upgrade definitions
- future `EnemyCatalog.gd`: enemy templates

Rule: data files should not create scene nodes.

## Layer 2: Simulation Models

Path: `scripts/simulation`

Owns gameplay state and deterministic-ish rules:

- `GameState.gd`: run state, spawning, player movement, firing, progression
- `EnemyModel.gd`: enemy position, hp, movement step
- future `WaveDirector.gd`: spawn pressure over time
- future `UpgradeSystem.gd`: applies selected upgrade effects

Rule: simulation exposes simple fields/events and does not draw.

## Layer 3: Projection

Path: `scripts/presentation/CylinderProjector.gd`

Converts logical tower coordinates to screen coordinates:

- sector + lane -> position
- depth -> scale
- depth -> alpha
- depth -> visibility

Rule: this layer knows math, not game rules.

## Layer 4: Rendering

Path: `scripts/presentation/TowerRenderer.gd`

Draws the current state:

- reactor shell
- visible grid points
- enemies
- player
- later: bullets, electricity, smoke, damage flashes

Rule: rendering reads state and requests redraws.

## Layer 5: Orchestration

Path: `scripts/core/Main.gd`

Connects systems:

- creates a new run
- binds renderer and HUD
- forwards preview input
- ticks simulation

Rule: orchestration wires pieces together but avoids becoming a god object.

## Layer 6: UI

Path: `scripts/ui`

Owns interface widgets:

- `Hud.gd`: run stats
- future `UpgradePicker.gd`
- future `TutorialOverlay.gd`
- future `RunResultScreen.gd`

Rule: UI may call high-level commands but should not mutate low-level fields directly.

## First Refactor Trigger

Split systems further when one file crosses either:

- 250 lines
- 3 unrelated responsibilities
- repeated logic in two features
