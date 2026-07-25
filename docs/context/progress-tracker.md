# Progress Tracker

## Current Phase

Phase 2 — implemented on branch `fase-2`, awaiting team playtest before merge to main

## Current Spec

None (Specs 002/003/004 implemented; Spec 005 next, Phase 3)

## Completed

- 2026-07-25 — Documentation package converted from .docx drafts to .md and synchronized: PROJECT-CONTEXT, game-overview, art-direction, Specs 001–005, ADR-001.
- 2026-07-25 — All open design questions resolved (see technical-decisions.md): movement-direction facing, 32 px tile, player 5 HP / enemy 1 hit, Fire Orb 1-hit linger, freeze = movement-lock only.
- 2026-07-25 — **Phase 0 complete:** feature folders, EventBus + GameState autoloads (TILE_SIZE = 32), input map (move/dash/attack/special, keyboard + gamepad), 1280x720 canvas_items window.
- 2026-07-25 — **Spec 001 (Player Controller) implemented:** 8-way movement, movement-direction facing (8-way snap), dash with enemy-only i-frames, PlayerStats.tres tunables, kick (damage half of Apprentice Boot), freeze support (movement-lock only).
- 2026-07-25 — **Spec 006 (Basic Enemy) written + implemented:** proximity detection (5 tiles), chase, melee attack on cooldown, discrete hits with white-flash + darkening tint, freeze support, EnemyStats.tres.
- 2026-07-25 — Graybox room_01 (20x11.25 tiles, 2x zoom camera) set as main scene. **Phase 1 deliverable met:** player enters room, enemy chases/attacks, enemy dies (2 kicks).

- 2026-07-25 — **Phase 2 implemented (branch `fase-2`):** Spec 002 Bag (pool, random draw, held/throw, signals), Spec 003 Magic Item Framework (MagicItemResource + polymorphic MagicItemEffect resources, state-independent countdown, escalating blink 2→10 Hz), Spec 004 Fire Orb (3s, 1-tile radius, 1s linger capped at 1 hit/target via DamageLingerZone). Kick now also redirects thrown/landed items +5 tiles. Automated smoke test (tests/) passes 11/11 checks.

## In Progress

- Team playtest of Phase 2 on branch `fase-2`

## Next Spec

Spec 005 — Right Hand of Ursula (Phase 3)

## Open Questions

None — all resolved as of 2026-07-25.

## Technical Debt

- Player death just reloads the scene (fine for jam; revisit for a real game-over in Phase 4/5).
- Kick targets enemies via group iteration (O(n)); fine for jam room sizes.
- ~~Enemy visuals mixed Polygon2D `color` and `modulate`~~ — resolved 2026-07-25: all feedback (flash, damage tint, freeze) is `modulate`-based and `Body` is typed as Node2D, so swapping graybox for Sprite2D/AnimatedSprite2D in Phase 4 requires zero code changes (keep the node named "Body").

## Architecture Decisions

- ADR-001 — No generative AI for art or audio assets.
- Player state machine is an enum inside player.gd (IDLE/MOVE/DASH), not a node-based FSM — "Holding" belongs to the Bag (Spec 002). Revisit only if states multiply.
- Damage flows inward via direct `take_damage()` calls; facts flow outward via signals (local + EventBus).

## Learning Summary

See learning-journal.md — session 2026-07-25 covers autoloads, Resources as tunables, enum FSM vs node FSM, and group-based decoupling.

## Resume Notes

- Branch `fase-2`: X/J draws the Fire Orb (blinking orange circle overhead, faster as it nears 3s), X/J again throws 2 tiles along facing, C/K kicks a landed item +5 tiles (or hits enemies if no item in reach). Explosion damages player too — friendly fire is live.
- Smoke test: `Godot.exe --path . res://tests/smoke_test.tscn` prints SMOKE PASS/FAIL.
- After playtest approval: merge `fase-2` → main, branch `fase-3`, implement Spec 005.
