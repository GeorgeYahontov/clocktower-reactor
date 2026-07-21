# MVP Plan

## Game Promise

`Clocktower Reactor` is a short-session mobile arcade roguelite where the player survives on the visible face of a rotating reactor tower. The trick is that danger continues to build around the cylinder, so rotation is both camera control and tactical positioning.

## First Playable Goal

Build a 3-minute run that proves:

- rotating pseudo-3D tower feels good
- threats can approach from sectors and lanes
- auto-fire gives constant action with low input burden
- progress is clear through energy, level-ups, and one boss beat

## Phase 2 Slice

Goal: make the prototype touchable and readable.

Included:

- touch drag tower rotation
- lower-screen lane taps
- visible automatic weapon traces
- energy pulse feedback on kills
- reactor integrity
- kill counter
- simple victory/defeat state
- short tutorial HUD copy

Still not included:

- upgrade picker
- boss
- polished mobile UI art
- sound
- real sprites

## Phase 3 Slice

Goal: make the run replayable.

Included:

- level-up choice screen
- six prototype upgrades
- upgrade effects applied through simulation state
- second enemy archetype: slow high-HP bulwark
- restart button after victory or defeat

Still not included:

- boss event
- upgrade rarity
- real balancing pass
- persistent meta-progression
- audio feedback

## Phase 3 Slice

Goal: make the run replayable.

Included:

- level-up choice screen
- six prototype upgrades
- upgrade effects applied through simulation state
- second enemy archetype: slow high-HP bulwark
- restart button after victory or defeat

Still not included:

- boss event
- upgrade rarity
- real balancing pass
- persistent meta-progression
- audio feedback

## MVP Loop

1. Player starts on the front face of the reactor.
2. Enemies spawn on tower sectors.
3. Player shifts lanes and rotates the tower.
4. Weapon fires automatically at nearby threats.
5. Defeated enemies drop energy.
6. Energy triggers upgrades.
7. After the timer reaches the end, a mini-boss event resolves the run.

## MVP Content

- 1 player shell
- 1 rotating tower arena
- 3 lanes
- 12 sectors
- 2 enemy types
- 1 hazard type
- 1 mini-boss
- 6 upgrades
- 1 tutorial
- 2 short levels

## Cut Line

These are intentionally out of MVP:

- online features
- procedural maps beyond spawn rules
- real 3D models
- complex inventory
- monetization
- character roster
- full meta-progression tree
