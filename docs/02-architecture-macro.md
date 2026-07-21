# Macro Architecture

## Engine Choice

Godot 4.7 Standard, using GDScript and a 2D scene tree.

The project uses pseudo-3D rendering instead of real 3D for the MVP. This keeps mobile performance and content creation simpler while preserving the main visual hook.

## Top-Level Modules

## Simulation

Pure game state:

- tower sectors and lanes
- player position
- enemy state
- timers
- waves
- upgrades
- run outcome

The simulation should avoid direct rendering calls.

## Presentation

Visual translation of simulation into screen-space:

- cylinder projection
- depth ordering
- scale and alpha by depth
- effects
- animation polish

Presentation can read state but should not own gameplay rules.

## Input

Mobile-first controls:

- drag or buttons for tower rotation
- lane movement
- later: ability button if needed

Desktop keyboard input exists only for fast preview.

## UI

Run information:

- timer
- energy
- level
- upgrade selection
- tutorial prompts
- pause and result screens

## Data

Config and balance:

- arena dimensions
- spawn timings
- enemy stats
- weapon stats
- upgrade definitions

The MVP keeps this in GDScript resources/classes. Later we can move balance to `.tres`, `.json`, or spreadsheets.

## Build/Release

Near-term:

- editor run on desktop
- Android export once the run loop exists

Later:

- export templates
- signing setup
- device testing checklist
