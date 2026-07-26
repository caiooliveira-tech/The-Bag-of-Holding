# Progress Tracker

## Current Phase

Phases 0–4, 4.5 (HUD + art), 4.6 (juice G1–G5), 6 A–C (walls, ranged enemy, smart chaser), **6.5 (Difficulty Levels)** and **Spec 022 (screen redesign + Title + Level Title)** complete on main, plus menus/audio/death screen and items Specs 011–012. Next: Phase 6 D–E (RunManager 20-room run, item-choice doors), then Phase 5 (ship).

## Current Spec

**Spec 023 — Cutscenes (Phase 4.7) — implemented** on branch `feature/cutscenes` (PR #7), 2026-07-28; awaiting playtest + team review.

- `systems/cutscenes/`: `CutsceneFrameResource` (text / art / layout / optional sfx) + `CutsceneResource` (frames + next_scene_path) + `intro.tres` (12 frames). `ui/cutscene/cutscene_player.gd|tscn` renders it; `intro_cutscene.tscn` binds the resource. Adding the ending cutscene is now pure data.
- Two layouts per Design's storyboard: DIALOGUE (art perched on a full-bleed `bg.png` banner, centered ink text) and READING (letter/Bag on one side, Euclidus's words in light text on the other, no banner).
- Typewriter reveal; a press completes the line, the next advances; ESC skips. Flow: New Game → difficulty → cutscene → room_01, **once per launch** via `GameState.intro_seen`.
- Art imported to `assets/cutscenes/` (raven/letter/bag). Smoke +4 data checks, **59/59 PASS**; layouts verified by scripted screenshots.
- Still open: caw SFX + optional cutscene music (Design); ending cutscene content.

Parked: **Spec 019 (floor-based difficulty, Phase 6.6)** on `feature/floor-difficulty`, PR #5 closed pending team alignment.

Queued next: Phase 6 D — Spec 016 (RunManager, 20-room run).

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

Nothing — Spec 018 merged. Next: Spec 015 (smart chaser, Phase 6 C).

## HUD trim + art integration (Phase 4.5) — merged 2026-07-26 (PR #3)

- **Phase 4.5 / Spec 009 (branch `feature/hud-special-slots`):** team decided 2026-07-26 the 🔺/⭕ special slots are post-MVP; MVP HUD = hearts (left) + held-item box moved to the right (provisional layout). Implemented 2026-07-26: PoolBox bag-pool removed, HeldSlot re-anchored right, art-ready texture hooks with graybox fallback — and HUD art **integrated** same day: wooden bar + item container (`assets/ui/`), item icons via `AtlasTexture` from `systems/magic_items/spritesheet.png` (+ `.json` frame coords) on both item `.tres`. Verified via scripted screenshots (both icons render). Smoke 21/21 PASS.
- 2026-07-26 — Heart art integrated: Design delivered `assets/ui/heart_filled.png` + `heart_empty.png`; hud.gd now takes both textures (filled/empty swap per health point, tint fallback if only filled is set), assigned in hud.tscn. HUD art is complete for the MVP layout.
- 2026-07-26 — **Room tiles integrated via TileMapLayer**: `rooms/room_tileset.tres` (32px atlas) + `rooms/room_tiles.gd` paints at runtime (`variant_row` 0 = blue/room 1, 1 = pink/room 2). Final template (region px, row 1 y=0 / row 2 y=32): closed door x224, open door x256, corner x288, wall x320, floor x352. Border = wall tile (sides rotated 90° so the inner face points into the room), corner tile only at the 4 corners, interior + door gaps = floor tile. **3 single-tile doors per room** (top x336, left/right at mid-height via ±90° node rotation); room.gd opens/listens to all doors under `Doors/` — all lead to next_scene_path (pick-a-door choice stays post-MVP). Collision split per gap (StaticBody2D, unchanged layer). Verified via `tests/screenshot_rooms.tscn`; smoke 21/21 PASS (includes 3-door check).

## Roguelike progression (Phase 6) — plan set, sub-phase A done — 2026-07-26

Plan in implementation-roadmap.md (Phase 6): a designed 20-room run (3 palette
acts: tutorial/escalation/mastery), smarter chaser + ranged shooter, maze walls,
per-run item unlocks. Team decisions: **hybrid authoring** (walls painted
per-room in scene; enemies/palette/order as RunManager data) + **item choice at
the door**. Sub-phases A(walls)→B(ranged+projectile)→C(smart chaser)→
D(RunManager/20 rooms)→E(door item unlock).

- **A — Interior walls + collision (done):** wall tiles added to
  `room_tileset.tres` (sheet cols 0–5 × rows 5–7 = closed / left-cap / h-middle /
  right-cap / corner / center, 3 palettes) with a physics layer (full-tile
  collision, collision_layer 1). Empty **`WallTiles` TileMapLayer** added to
  room_01/02 for designers to paint mazes in-editor; collision is automatic from
  the tileset. **Walls block movement, area effects, and enemy vision** — added
  a raycast line-of-sight gate (mask 1) to the three area effects + DamageLingerZone
  (`MagicItemEffect.wall_blocks`) and to enemy detection (`_can_see_player`). Smoke
  +4 checks (wall collision, explosion in-open vs. behind-wall, no-LoS no-chase);
  the test now clears painted walls at start for predictable positions. 31/31 PASS.
  NOTE: wall palette rows (brown/teal/green) will be paired to room floor palettes
  in sub-phase D (RunManager).
- **B — Ranged enemy + projectile (Spec 014, done):** `entities/projectiles/
  enemy_projectile` (Area2D, sheet 160,0) flies straight, damages the player,
  despawns on walls (mask 1+2); in group `projectiles` so dash/i-frames treat it
  as enemy damage. `EnemyStats` gains `is_ranged`/`preferred_distance_tiles`/
  `shoot_cooldown`; `enemy.gd` branches to kite+shoot vs. chase+melee (`enemy2`
  → `ranged_shooter.tres`, `enemy1` stays melee). Firing plays shot.mp3 via
  `EventBus.enemy_shot`. Smoke +2 (ranged shot damages in the open; projectile
  stopped by a wall), 33/33 PASS.
- **C — Smart chaser (Spec 015, done):** the melee enemy replaced the magnet with
  steering (separation so they don't clump + a per-enemy strafe/flank + raycast
  wall-avoidance) and a **telegraphed lunge** state machine (CHASE → WINDUP crouch
  → committed LUNGE with one contact hit → RECOVER), all parameterized on
  `EnemyStats`. Ranged archetype unchanged. Smoke +2 (two chasers separate;
  telegraphed lunge damages), 36/36 PASS.

## Screen redesign + Title + Level Title (Spec 022) — 2026-07-27

Art pass over the front-end using `assets/screens/` (brick wall, scroll,
banner, hanging sign, crow) + `logo-jogo.png`. New shared `ui/menu/menu_ui.gd`
(`class_name MenuUI`, static builders + tokens) drives brick backdrop, parchment
panels, logo and text across every screen — no per-screen art duplication.
- **Title Screen** (`ui/menu/title_screen.*`, now `main_scene`): logo on a scroll
  + pulsing "PRESS ANY BUTTON TO START"; any key/pad/click → menu. Boot splash is
  now black with `show_image=false` (blank), so the Title fades in "fresh".
- **Main menu / Options / Credits / Pause / Difficulty select** rebuilt on MenuUI;
  behavior unchanged (same options/controls/difficulty flow/ESC routes). Crow art
  first shipped with an opaque white box (interim mechanical cut-out); Design then
  delivered a transparent `img-main-menu.png`, so the cut-out was dropped and the
  helper points straight at the delivered asset.
- **Level Title**: `EventBus.level_entered(title)` + `LevelTitle` autoload
  (CanvasLayer) drops `bg2.png` from the top over a black dim overlay (fades in
  with the drop, out with the lift), holds ~1.4 s. `Room` gained `@export
  level_title`; room_01 = "1st Floor - Room A", room_02 = "…Room B".
- Layout pass (Caio feedback): menu + pause use a corner-anchored logo parchment
  (`bg-logo-main-menu.png`, flush top-left, delivered pre-cropped) via
  `MenuUI.corner_logo`; menu + difficulty descriptions sit beside the buttons,
  top-aligned to the first button.
- Verified via `tests/screenshot_screens.tscn` (title/menu/options/credits/
  difficulty/level-title/pause all render to spec). Smoke 43/43 PASS. Awaiting playtest.

## Phase 6.5 — Difficulty Levels (Spec 018) — merged 2026-07-27 (PR #4)

Three levels selected after New Game — Apprentice / Wizard / Archmage. `systems/difficulty/` (DifficultyResource + 3 .tres); `GameState.difficulty` defaults to Wizard = the pre-difficulty balance exactly (zero drift, smoke-asserted) and survives reset_run. Enemies compute `applied_*` stats at spawn (speed/cooldowns/detection — base .tres never mutated); player max health + G3 i-frame duration come from the difficulty; HUD heart bar clones its template heart to match (Apprentice = 7 hearts). `ui/menu/difficulty_select` in the wooden-button style (hotkeys 1/2/3, Wizard pre-selected, ESC back). **Item countdowns never scale** (technical-decisions.md). Playtest tune: Apprentice enemy speed 0.85 → 0.7. Smoke 41/41 PASS. Open: flavor text (Design), Archmage speed feel.

## Death screen, pause-key control, web audio, hit-sound trim — 2026-07-26

- **Death screen** (`ui/menu/death_screen.gd`, autoload `DeathScreen`): on
  `player_died`, freezes the game, fades in a centered "YOU DIED" (game font) +
  game_over SFX, holds ~3.2 s, then returns to the main menu. Player death no
  longer reloads the room; player_death SFX plays on the lethal hit.
- **Options CONTROLS** now lists PAUSE → ESC (the ask was to show the pause key,
  not to embed options in pause — the brief embedding experiment was reverted).
- **Web audio unlock:** on web, music is held until the first key/click so it
  starts on the first menu interaction (browsers block autoplay).
- **player_hit SFX** starts 0.08 s in (SFX_SKIP) to cut a silent lead-in.
- **room_cleared / player_death / game_over** mp3s imported and wired.

## Pause menu, HUD heart animation, menu music fade-cut — 2026-07-26

- **Pause menu** (`ui/menu/pause_menu.gd`, autoload `Pause`): ESC during
  gameplay pauses (get_tree().paused) and shows a wooden-button menu in the
  main-menu style — RESTART LEVEL / OPTIONS / QUIT TO MAIN MENU / EXIT GAME,
  keyboard nav, ESC resumes. Gated to gameplay (a `player` node exists), so it
  never fires in menus. AudioManager set to PROCESS_MODE_ALWAYS so music/clicks
  survive the pause. (OPTIONS routes to the options scene, whose ESC returns to
  the main menu — losing the run; refine to an overlay later if wanted.)
- **HUD hearts:** full hearts float up half a heart, empty ones sit centered in
  the bar; the swap is now **tweened** (a lost life drops into its socket, a
  gained one pops up). Only visible at partial health — at 5/5 all are raised.
- **Menu music:** starts 3 s in (via `loop_offset`) to cut the track's fade-in,
  on the first play and every loop. Tunable in AudioManager.MUSIC_SKIP.

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

Phase 6 C — Spec 015 (smart chaser), then D (Spec 016, RunManager 20-room run) and E (Spec 017, item-choice doors). Phase 5 (ship/itch.io) after Phase 6 lands.

## Open Questions

- Difficulty select flavor text — placeholder shipping; Design (Silas/Flavio) to bless or rewrite (`ui/menu/difficulty_select.gd`).
- Archmage enemy speed (×1.15) — does it read in play? Apprentice was tuned to 0.7 after Rafael's playtest; Archmage awaits the same scrutiny.

## Technical Debt

- **Stale logo asset (found 2026-07-28):** `assets/logo-jogo.png` is still the OLD wordmark ("THE BAG OF NO BOTTOM"); the current logo is "THE BAG OF HOLDING". Verified by screenshotting the live title screen. It is preloaded once as `MenuUI.LOGO` and reused by the Title screen, main-menu header and Credits — so **replacing that one file fixes all three with zero code changes**. Blocked on Design delivering the new PNG (not in the repo or Downloads).

- Smoke test / headless boot report a few "ObjectDB instances leaked at exit" warnings — **pre-existing** (verified present on main without the Spec 018 changes, 2026-07-27); harmless force-quit artifacts, but worth a `--verbose` look before Phase 5 ship.
- Player death just reloads the scene (fine for jam; revisit for a real game-over in Phase 4/5).
- Kick targets enemies via group iteration (O(n)); fine for jam room sizes.
- ~~Enemy visuals mixed Polygon2D `color` and `modulate`~~ — resolved 2026-07-25: all feedback (flash, damage tint, freeze) is `modulate`-based and `Body` is typed as Node2D, so swapping graybox for Sprite2D/AnimatedSprite2D in Phase 4 requires zero code changes (keep the node named "Body").

## Architecture Decisions

- ADR-001 — No generative AI for art or audio assets.
- Player state machine is an enum inside player.gd (IDLE/MOVE/DASH), not a node-based FSM — "Holding" belongs to the Bag (Spec 002). Revisit only if states multiply.
- Damage flows inward via direct `take_damage()` calls; facts flow outward via signals (local + EventBus).

## Learning Summary

See learning-journal.md — sessions 2026-07-25 → 2026-07-27 cover autoloads, Resources as tunables, enum FSM vs node FSM, group-based decoupling, HUD anchor/NinePatch/AtlasTexture patterns, resource-caching pitfalls, and the difficulty-as-data design.

## Reminders — Shoelace spritesheet: DONE (2026-07-25)

Both steps completed: `Body` is now the AnimatedSprite2D (32x32 frames from SHEETS_SHOELACE_INIMIGOS_ITENS_PROJETIL.png, nearest filtering) and player.gd plays `walk_front/walk_back/walk_left/walk_right` from `facing` (horizontal wins diagonals; idle holds frame 0; frozen holds pose). Modulate-based feedback (flash/freeze tint) carried over unchanged. FacingPivot is hidden but still aims throws/kicks.

## Resume Notes

- Main is fully playable: menu → difficulty select → room_01 → room_02 → win; pause (ESC), death screen, audio, juice all live. 4 items in the pool; melee + ranged enemies; walls with LoS.
- Smoke test: `godot --headless --path . res://tests/smoke_test.tscn` (41 checks). Door-crossing/scene-change is playtest-only (change_scene would kill the test container).
- Known pre-existing: a few ObjectDB exit-leak warnings on headless runs (tech debt, check before ship).
