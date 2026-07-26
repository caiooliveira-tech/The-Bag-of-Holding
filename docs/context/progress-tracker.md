# Progress Tracker

## Current Phase

Phases 0–4 complete and merged to main. **Phase 4.5 (HUD trim, Spec 009) in progress on branch `feature/hud-special-slots`** — draft PR #3 open for team review. **Phase 5 (ship) intentionally on hold** — the team will rethink the roadmap first (menu scene and other new steps to be defined).

## Current Spec

Spec 009 — HUD: MVP trim to hearts + held item (special slots → post-MVP). MVP scope implemented on the branch; awaiting team review/playtest before merge.

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

- **Phase 4.5 / Spec 009 (branch `feature/hud-special-slots`, PR #3 draft):** team decided 2026-07-26 the 🔺/⭕ special slots are post-MVP; MVP HUD = hearts (left) + held-item box moved to the right (provisional layout). Implemented 2026-07-26: PoolBox bag-pool removed, HeldSlot re-anchored right, art-ready texture hooks with graybox fallback — and HUD art **integrated** same day: wooden bar + item container (`assets/ui/`), item icons via `AtlasTexture` from `systems/magic_items/spritesheet.png` (+ `.json` frame coords) on both item `.tres`. Verified via scripted screenshots (both icons render). Smoke 21/21 PASS. Awaiting team review.
- 2026-07-26 — Heart art integrated: Design delivered `assets/ui/heart_filled.png` + `heart_empty.png`; hud.gd now takes both textures (filled/empty swap per health point, tint fallback if only filled is set), assigned in hud.tscn. HUD art is complete for the MVP layout.
- 2026-07-26 — **Room tiles integrated via TileMapLayer**: `rooms/room_tileset.tres` (32px atlas) + `rooms/room_tiles.gd` paints at runtime (`variant_row` 0 = blue/room 1, 1 = pink/room 2). Final template (region px, row 1 y=0 / row 2 y=32): closed door x224, open door x256, corner x288, wall x320, floor x352. Border = wall tile (sides rotated 90° so the inner face points into the room), corner tile only at the 4 corners, interior + door gaps = floor tile. **3 single-tile doors per room** (top x336, left/right at mid-height via ±90° node rotation); room.gd opens/listens to all doors under `Doors/` — all lead to next_scene_path (pick-a-door choice stays post-MVP). Collision split per gap (StaticBody2D, unchanged layer). Verified via `tests/screenshot_rooms.tscn`; smoke 21/21 PASS (includes 3-door check).

## Polish pass (branch `feature/main-menu`) — 2026-07-26

- **Menu:** Load Game button hidden (no save system yet); the description beside
  the buttons now adapts to the selected option, in the intro's tone of voice.
- **Frozen bug fixed:** a frozen player can no longer draw/throw/kick — freeze
  now locks the bag and boot too, not just movement (player only; enemies still
  attack while frozen). See technical-decisions.md; smoke check updated.
- **Audio (Spec 013):** new `AudioManager` autoload — looping music (menu vs.
  in_game) + EventBus-driven one-shot SFX (draw/throw/per-item explosions/hits/
  dash/kick/door/room-clear/menu clicks). Added EventBus signals `enemy_damaged`,
  `player_dashed`, `player_kicked`, `door_opened`. New mp3s imported. Smoke 27/27 PASS.

## Main menu (branch `feature/main-menu`) — implemented 2026-07-26

New front-end scenes under `ui/menu/` (code-driven, Dellas font + wooden button art):
- **main_menu**: title + wooden buttons (New Game / Load Game / Options / Credits /
  Exit Game), keyboard nav (W/S or ↑/↓, Enter/Space, or the hotkey letter). New Game →
  room_01, Options/Credits → their scenes, Exit → quit. Load Game is a no-op (no save
  system yet). `project.godot` main scene is now the menu.
- **options_menu**: resolution dropdown (720/900/1080 16:9) + fullscreen toggle (both
  functional via DisplayServer); CONTROLS list read **live from the InputMap** (auto-
  reflects the team's control remap). ESC → menu.
- **credits**: contributor list (mock names + real roles). ESC → menu.
Screens verified against the design mocks by screenshot. Smoke 27/27 still PASS.

## New items (Specs 011 + 012, branch `feature/items-left-hand-troy`) — implemented 2026-07-26

Two catalog items pulled forward from the post-MVP cut list:
- **Left Hand of Ursula (Spec 011):** `KnockbackAreaEffect` (new `MagicItemEffect` subclass —
  framework untouched again) shoves everyone in radius away from the blast center; enemies
  gained `apply_knockback`/decay like the player; 3s, 1-tile radius, purple ring + shove
  particles + medium camera shake. Sheet icon (192, 64).
- **Troy the Wooden Horse (Spec 012):** a normal bomb (countdown/blink/despawn) whose *throw*
  is an L-charge instead of a 2-tile hop — `charge_on_throw` on MagicItemResource; raycast
  wall detection + one 90° turn-toward-open; contact damage once per target; launch grace so
  the thrower isn't hit at spawn (but the L-return can hit them — pillar 4); `effect` is null,
  `_trigger` guards it. Sheet icon (192, 96). L-turn verified by screenshot.
- Both added to `item_pool.tres` (draw pool now 4 items). Smoke test +3 checks (knockback
  shove, Troy contact damage, Troy charge distance), 27/27 PASS.

## Game Feel (Spec 010, Phase 4.6) — G1–G5 all implemented (branch per sub-phase)

Spec 010 written 2026-07-26: phased juice pass (G1 impact core → G2 item motion →
G3 survivability/i-frames → G4 action personality → G5 atmosphere). EventBus-driven,
no balance drift except G3's post-hit i-frames (needs a team call).

- **G1 (branch `fase-4.6-g1`) implemented 2026-07-26:** trauma-based camera shake
  (`systems/juice/game_camera.gd` on each room Camera2D; explosion +0.5, hit +0.35,
  death +0.2; freeze does NOT shake), enemy death pop (flash + scale + `ImpactBurst`
  CPUParticles2D + 30 ms hitstop, then free), player damage pack (knockback via
  PlayerStats, 50 ms hitstop, red edge vignette `ui/screen_fx.tscn`). New autoload
  `Juice` (global hitstop). `EventBus.item_effect_triggered` now carries `effect_kind`
  (from `MagicItemEffect.effect_kind()`). Smoke 21/21 PASS. Awaiting playtest.
  NOTE: new `class_name` scripts are preloaded by path in CLI-reached code (ImpactBurst)
  to dodge the global class-cache miss on headless/smoke runs.
- **G5 (branch `fase-4.6-g5`) implemented 2026-07-26 (subset):** idle bob on player +
  enemy (only while still/telegraph, not frozen/dying), dust puff on door open, gold
  screen-clear vignette flash (`room_cleared`), gamepad rumble hooks in `Juice` (no-op
  on keyboard). Cut from G5: per-tile ambient, camera-on-door-open. Smoke 24/24 PASS.
- **G4 (branch `fase-4.6-g4`) implemented 2026-07-26:** draw overshoot (item springs
  0→1.2→1.0 elastic on draw), urgency pulse (item scale pulses with the blink when
  urgency > 0.6, skipped in flight), explosion ring (`systems/juice/expanding_ring.gd`
  on area_damage trigger), dash ghost trail (fading sprite after-images). Smoke 24/24 PASS.
- **G3 (branch `fase-4.6-g3`) implemented 2026-07-26:** post-hit i-frames
  (`PlayerStats.hit_iframe_duration` = 0.5s, set 0 to disable) blocking ENEMY damage
  only — unified with dash i-frames via `_is_enemy_invulnerable()`; own item effects
  always connect (pillar 4). Sprite alpha-blinks through the window. **Difficulty
  change — team approved 2026-07-26; tune the duration if too easy.** Smoke test +3
  checks (hit lands, second hit blocked, own damage ignores i-frames), 24/24 PASS.
- **G2 (branch `fase-4.6-g2`) implemented 2026-07-26:** landing marker
  (`systems/juice/landing_marker.gd`) draws the blast footprint at the landing spot
  during flight (radius from `MagicItemEffect.preview_radius_tiles()`); item visual
  hops on a parabola with squash-and-stretch + 2 decaying bounces on landing, kicked
  items spin — all on the visual child only, real position/countdown unchanged
  (smoke still measures 64px throw). Freeze feel: camera zoom-punch instead of shake,
  ice-shard particles, icy thaw flash on player + enemy. Smoke 21/21 PASS.

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

## Reminders — Shoelace spritesheet: DONE (2026-07-25)

Both steps completed: `Body` is now the AnimatedSprite2D (32x32 frames from SHEETS_SHOELACE_INIMIGOS_ITENS_PROJETIL.png, nearest filtering) and player.gd plays `walk_front/walk_back/walk_left/walk_right` from `facing` (horizontal wins diagonals; idle holds frame 0; frozen holds pose). Modulate-based feedback (flash/freeze tint) carried over unchanged. FacingPivot is hidden but still aims throws/kicks.

## Resume Notes

- Branch `fase-4`: full loop playable — telegraph beat, combat, clear, green door, room_02 (3 enemies), win screen (Attack restarts). Hearts top-left, held item top-right. Health persists between rooms; death restarts the current room at full HP.
- Smoke test: `Godot.exe --path . res://tests/smoke_test.tscn` (21 checks). Door-crossing/scene-change is playtest-only (change_scene would kill the test container).
- After playtest approval: merge `fase-4` → main, branch `fase-5`: balance pass, Web export preset, itch.io upload before the July 26 deadline.
