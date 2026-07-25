# Progress Tracker

## Current Phase

Phase 2 — Core Game Mechanic (Bag / Magic Items)

## Current Spec

Spec 002 — Bag System

## Completed

- 2026-07-25 — Documentation package converted from .docx drafts to .md and synchronized: PROJECT-CONTEXT, game-overview, art-direction, Specs 001–005, ADR-001.
- 2026-07-25 — All open design questions resolved (see technical-decisions.md): movement-direction facing, 32 px tile, player 5 HP / enemy 1 hit, Fire Orb 1-hit linger, freeze = movement-lock only.
- 2026-07-25 — **Phase 0 complete:** feature folders, EventBus + GameState autoloads (TILE_SIZE = 32), input map (move/dash/attack/special, keyboard + gamepad), 1280x720 canvas_items window.
- 2026-07-25 — **Spec 001 (Player Controller) implemented:** 8-way movement, movement-direction facing (8-way snap), dash with enemy-only i-frames, PlayerStats.tres tunables, kick (damage half of Apprentice Boot), freeze support (movement-lock only).
- 2026-07-25 — **Spec 006 (Basic Enemy) written + implemented:** proximity detection (5 tiles), chase, melee attack on cooldown, discrete hits with white-flash + darkening tint, freeze support, EnemyStats.tres.
- 2026-07-25 — Graybox room_01 (20x11.25 tiles, 2x zoom camera) set as main scene. **Phase 1 deliverable met:** player enters room, enemy chases/attacks, enemy dies (2 kicks).

## In Progress

- Phase 2: Spec 002 (Bag) → Spec 003 (Magic Item Framework) → Spec 004 (Fire Orb)

## Next Spec

Spec 002 — Bag System

## Open Questions

None — all resolved as of 2026-07-25.

## Technical Debt

- Player death just reloads the scene (fine for jam; revisit for a real game-over in Phase 4/5).
- Kick targets enemies via group iteration (O(n)); fine for jam room sizes.
- Enemy visuals: freeze tint uses `modulate`, damage state uses Polygon2D `color` — replace when real sprites land.

## Architecture Decisions

- ADR-001 — No generative AI for art or audio assets.
- Player state machine is an enum inside player.gd (IDLE/MOVE/DASH), not a node-based FSM — "Holding" belongs to the Bag (Spec 002). Revisit only if states multiply.
- Damage flows inward via direct `take_damage()` calls; facts flow outward via signals (local + EventBus).

## Learning Summary

See learning-journal.md — session 2026-07-25 covers autoloads, Resources as tunables, enum FSM vs node FSM, and group-based decoupling.

## Resume Notes

- Playable now: WASD/arrows move, Space/Shift dash, C/K kick (kills the enemy in 2 hits), X/J attack (emits signal; Bag lands in Spec 002).
- Next: Spec 002 Bag System — pool, random draw, held-follows-player, throw 2 tiles, countdown from draw.
