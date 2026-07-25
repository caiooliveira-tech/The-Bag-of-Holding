# Spec 001 - Player Controller

**Status:** Not Started

## Goal

Implement Shoelace's movement, dodge, and attack input handling — the player's core moment-to-moment feel, decoupled from the Bag/item logic itself (see Spec 002).

## Gameplay Description

The player moves in 8 directions, can dash to dodge enemy attacks, and triggers the Attack action to draw/hold/throw an item from the Bag. The Player Controller owns movement, dashing, and facing — it does not own item state; it only sends draw/throw input events to the Bag system and reacts to its signals.

## Player Experience

Should feel nimble but vulnerable — the dash buys a brief safety window against enemies, but never against the countdown the player is carrying. Positioning matters more than reaction speed.

## Functional Requirements

- 8-directional movement (4 cardinal + 4 diagonal).
- **Facing is movement-direction-based** (decided 2026-07-25): facing = last non-zero movement direction. No mouse aiming. Facing determines throw direction and kick-aim for the Apprentice Boot special.
- Dash/dodge in the current movement input direction; grants invulnerability to enemy damage only, for the dash's duration. It must not protect against the player's own held/thrown magic item effects.
- Move speed, dash speed, dash duration, and dash cooldown are exported values on a PlayerStats Resource — no magic numbers in code.
- Attack input triggers a "draw" request to the Bag system (Spec 002); the Player Controller does not itself track which item is held or its timer.
- Player health: **5 hits** (max_health = 5 on PlayerStats). Enemy attacks deal 1 hit each.

## Non-Functional Requirements

- Must feel responsive at a 60fps target.
- Input/movement reads happen in `_physics_process` only; no `get_node()`/`$` lookups inside per-frame callbacks (per godot-standards.md).

## Scene Structure

`entities/player/player.tscn` — root movement body, sprite/animation, hurtbox, and (if states exceed ~3 exclusive modes) a state machine node per godot-standards.md.

## Nodes

- Movement body (root)
- Sprite/AnimatedSprite
- Hurtbox Area (receives both enemy damage and the player's own item effects)
- Facing/throw-origin Marker

## Scripts

- `player.gd` — input, movement, dash state
- `player_state_machine.gd` — only if idle/move/dash/holding-item states warrant it (likely yes, per the >3-modes rule in godot-standards.md)

## Signals

- `dash_started`
- `dash_ended`
- `damage_taken(amount, source)`

## Resources

- `PlayerStats` — move_speed, dash_speed, dash_duration, dash_cooldown, max_health

## Acceptance Criteria

- 8-way movement works cleanly in all directions.
- Dash grants i-frames against enemy damage only.
- Facing direction correctly feeds throw/kick aiming.
- All tunables live on PlayerStats, not hardcoded.

## Test Cases

- Player moves correctly in all 8 directions and stops cleanly on release.
- Dash blocks damage from an enemy attack mid-dash.
- Dash does not block damage from the player's own item detonating during the dash.
- Facing direction is retained correctly when the player stops moving.

## Out of Scope

- Bag draw/hold/throw logic itself (Spec 002)
- Magic item effect resolution (Spec 003 + per-item specs)
- Health/death handling beyond receiving damage (future Enemy/Health spec, Phase 2)
