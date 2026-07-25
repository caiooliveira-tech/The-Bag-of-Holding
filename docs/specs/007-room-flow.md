# Spec 007 - Room Flow (State Machine, Doors, Transitions)

**Status:** Implemented (2026-07-25)

## Goal

Turn the prototype into a game loop: enter room → brief calm beat → combat → clear → door opens → next room, per the core loop in PROJECT-CONTEXT §3.

## Gameplay Description

Each room starts in a short telegraph moment (enemies visible but inactive), then combat begins. When the last enemy dies, the door opens (visual change + collision off) and walking through it loads the next room. Player health persists across rooms; death restarts the current room at full health.

## Functional Requirements

- Room state machine (per game-architecture.md): `WAITING` (telegraph, default 1 s) → `COMBAT` → `CLEARED`.
- Enemies are inactive (no chase/attack) during WAITING; they still take damage at any time.
- Room counts its own enemies at ready and listens to `EventBus.enemy_died`; on zero alive → CLEARED, emit `EventBus.room_cleared`, open the door.
- Door: closed = wall-like blocker; open = green-lit passage (Area2D) that detects the player and triggers the transition.
- Transition: store player health in GameState, increment `current_room`, `change_scene_to_file(next_scene_path)` (exported per room).
- MVP room chain: room_01 (1 enemy) → room_02 (3 enemies) → win screen (Attack restarts the run).
- Player death resets stored health and reloads the current room.

## Scene Structure

- `rooms/room.gd` on each room root; `rooms/door.tscn` instanced into the top wall gap.
- `ui/win_screen.tscn` — end-of-run placeholder.

## Signals

- Door: `player_entered(player)`
- EventBus: `room_cleared` (already declared)

## Acceptance Criteria

- Enemies hold still for the telegraph beat, then aggro normally.
- Door opens exactly when the last enemy dies.
- Health carries over between rooms; death restarts the room at full health.

## Out of Scope (explicit MVP cuts)

- Power-up/item choice at doors — the item-discovery system is post-MVP (game-overview.md); doors are plain passages for the jam.
- Multiple doors per room; room counter UI.
