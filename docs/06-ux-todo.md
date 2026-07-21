# UX TODO

## Context

Playtest screenshot from 2026-07-22 shows that the current screen is not user friendly enough. The pseudo-3D cylinder dominates the whole viewport, the radar competes with active gameplay, the bottom tutorial text is clipped, and upgrade cards take too much space while the player is trying to understand the core loop.

Current priority: pause feature growth and make the first screen readable.

## P0 - Unload The First Screen

- Reduce the reactor visual footprint by 15-25% so the scene has more breathing room.
- Move the radar into a fixed HUD zone so it does not float over active objects.
- Hide long tutorial text behind the help menu or a first onboarding step.
- Keep only one short live hint on the game screen.
- Make upgrade cards compact: icon + short title first, description only on focus/help/long press.
- Verify that bottom text is not clipped at 720x1280 and similar mobile viewports.

## P0 - Make The Core Loop Obvious

- Clearly mark the front work zone where vents close and player actions happen.
- Make the radar supportive, not mandatory for basic play.
- Keep the mobile core input simple: lane up/down plus pulse as the primary gesture set.
- Re-test whether Reactor Autopilot actually makes play easier or only hides the rotation problem.
- Make vents visually explain their purpose: open vent = danger/pressure leak, closed vent = stabilized sector.

## P1 - Make The Reactor Feel Like A Physical Object

- Rework the reactor body into a more solid object: fewer wireframe rings, more panels, ribs, and mechanical anchors.
- Increase contrast between the active front zone and decorative tower structure.
- Tie visual reactor progression to specific upgrades, not only upgrade count.
- Improve enemies and vents so they remain readable against the reactor body.
- Replace unclear transparent-layer language with visible machine parts and readable silhouettes.

## P1 - Upgrades And HUD

- Prevent upgrade choices from covering the tutorial or main play area.
- Convert upgrades into mini-picks: two buttons around 40-56px high, with one-line descriptions.
- Add clear icons for upgrade types: armor, charge, vent, reactor, pulse.
- Add a mute/sound toggle inside the `?` menu.
- Add short labels or icons to the three HUD bars so their meaning is readable at a glance.

## P2 - Validation Checklist

- Take desktop and mobile screenshots after every visual pass.
- Run a 60-second manual playtest: can the goal be understood without reading docs?
- Check that Godot preview does not clip text at 720x1280.
- Check that no UI element overlaps the active reactor, radar, or upgrade choices.
- Keep screenshots in the dev notes when a visual change is mainly about readability.

## Design Direction Notes

- Do not add more mechanics until the first-screen readability problem is improved.
- Do not rely on transparency to explain depth.
- Keep sound and reactor progression, but make them secondary to clear visuals and controls.
- Next development phase should be a UX cleanup pass before another gameplay feature pass.