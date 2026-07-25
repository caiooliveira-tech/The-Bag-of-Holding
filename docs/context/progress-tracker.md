# Progress Tracker

## Current Phase

Phases 0–4 complete and merged to main. **Phase 5 (ship) intentionally on hold** — the team will rethink the roadmap first (menu scene and other new steps to be defined).

## Current Spec

None (Specs 001–008 all implemented)

## Completed

- 2026-07-25 — Documentation package converted from .docx drafts to .md and synchronized: PROJECT-CONTEXT, game-overview, art-direction, Specs 001–005, ADR-001.
- 2026-07-25 — All open design questions resolved (see technical-decisions.md): movement-direction facing, 32 px tile, player 5 HP / enemy 1 hit, Fire Orb 1-hit linger, freeze = movement-lock only.
- 2026-07-25 — **Phase 0 complete:** feature folders, EventBus + GameState autoloads (TILE_SIZE = 32), input map (move/dash/attack/special, keyboard + gamepad), 1280x720 canvas_items window.
- 2026-07-25 — **Spec 001 (Player Controller) implemented:** 8-way movement, movement-direction facing (8-way snap), dash with enemy-only i-frames, PlayerStats.tres tunables, kick (damage half of Apprentice Boot), freeze support (movement-lock only).
- 2026-07-25 — **Spec 006 (Basic Enemy) written + implemented:** proximity detection (5 tiles), chase, melee attack on cooldown, discrete hits with white-flash + darkening tint, freeze support, EnemyStats.tres.
- 2026-07-25 — Graybox room_01 (20x11.25 tiles, 2x zoom camera) set as main scene. **Phase 1 deliverable met:** player enters room, enemy chases/attacks, enemy dies (2 kicks).

- 2026-07-25 — **Phase 2 implemented (branch `fase-2`):** Spec 002 Bag (pool, random draw, held/throw, signals), Spec 003 Magic Item Framework (MagicItemResource + polymorphic MagicItemEffect resources, state-independent countdown, escalating blink 2→10 Hz), Spec 004 Fire Orb (3s, 1-tile radius, 1s linger capped at 1 hit/target via DamageLingerZone). Kick now also redirects thrown/landed items +5 tiles. Automated smoke test (tests/) passes 11/11 checks.

- 2026-07-25 — Phase 2 playtested and merged to main.
- 2026-07-25 — **Phase 3 implemented (branch `fase-3`):** Spec 005 Right Hand of Ursula (FreezeAreaEffect subclass + .tres — zero base-class changes, proving the framework), player freeze tint, freeze flash visual, pool now holds both MVP items. Smoke test extended to 19 checks (deterministic per-section pools), SMOKE PASS.

- 2026-07-25 — Phase 3 playtested and merged to main.
- 2026-07-25 — **Phase 4 implemented (branch `fase-4`):** Specs 007 (room flow) + 008 (HUD) written then coded. Room state machine (WAITING telegraph → COMBAT → CLEARED), Door (blocker→green passage), room_01 → room_02 (3 enemies) → win screen chain, health persistence via GameState, HUD (5 hearts + held-item slot, EventBus-only). Smoke test: 21 checks, SMOKE PASS.

- 2026-07-25 — Phase 4 playtested (HUD aligned to Flavio's wireframe: hearts left, drawn-item picture center, bag pool right) and merged to main.

## In Progress

- Art integration started in-editor (uncommitted): shoelace.png 4-direction spritesheet wired into an AnimatedSprite2D on player.tscn (hidden for now), concept jpegs replaced by transparent pngs.

## Next Spec

Roadmap revision (team): add menu scene and other new steps, then decide when Phase 5 (export/itch.io) happens.

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

## Reminders — activating the Shoelace spritesheet (art WIP in player.tscn)

1. When switching to the real sprite: **delete the Polygon2D `Body` and rename the AnimatedSprite2D to `Body`** (and make it visible). All feedback (damage flash, freeze tint) is modulate-based on a Node2D named "Body", so it works on the sprite with zero code changes.
2. player.gd needs ~5 lines to play the right animation (`front`/`back`/`left`/`right`) from the existing `facing` vector — ask Claude when ready.

## Resume Notes

- Branch `fase-4`: full loop playable — telegraph beat, combat, clear, green door, room_02 (3 enemies), win screen (Attack restarts). Hearts top-left, held item top-right. Health persists between rooms; death restarts the current room at full HP.
- Smoke test: `Godot.exe --path . res://tests/smoke_test.tscn` (21 checks). Door-crossing/scene-change is playtest-only (change_scene would kill the test container).
- After playtest approval: merge `fase-4` → main, branch `fase-5`: balance pass, Web export preset, itch.io upload before the July 26 deadline.
