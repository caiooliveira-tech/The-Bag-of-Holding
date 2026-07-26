# Learning Journal

## Session Template

### Feature

### What was implemented

### Why this architecture?

### Alternatives considered

### Godot concepts learned

### Common mistakes

### Suggested exercises

### References

---

## Session 2026-07-25 — Phase 0 + Phase 1 (Foundation, Player, Enemy)

### Feature

Project foundation (autoloads, input map), Spec 001 Player Controller, Spec 006 Basic Enemy, graybox room.

### What was implemented

- `autoloads/event_bus.gd` + `autoloads/game_state.gd` registered in project.godot; `GameState.TILE_SIZE = 32` and `tiles()` as the single tile→pixel conversion point.
- `entities/player/`: player.tscn (CharacterBody2D + Polygon2D graybox + FacingPivot + Hurtbox), player.gd (8-way move, dash, facing, kick), player_stats.gd/.tres.
- `entities/enemies/`: enemy.tscn, enemy.gd (detect → chase → attack, freeze, hit flash/tint), enemy_stats.gd/melee_grunt.tres.
- `rooms/room_01.tscn`: floor/wall ColorRects, StaticBody2D walls, Camera2D at 2x zoom.

### Why this architecture?

- **Autoload EventBus**: signals need a stable, always-present owner so freeable nodes (enemies) never hold references to each other. Emitters announce facts; whoever cares connects in `_ready()`.
- **Resources for tunables** (PlayerStats/EnemyStats): balancing without touching code, and ranged-vs-melee later becomes a `.tres` variant, not a new script.
- **Enum FSM in player.gd** instead of a node-based state machine: only 3 exclusive states exist so far (IDLE/MOVE/DASH). "Holding" is Bag state (Spec 002), not player state.
- **Damage inward via direct calls** (`take_damage()`), facts outward via signals — matches game-architecture.md's communication rule and avoids signal chains.

### Alternatives considered

- Node-per-state FSM (scales better, more files/indirection — deferred until states multiply).
- Area2D hitbox/hurtbox pairs for melee (more general, more setup — direct call is enough for a proximity melee in a jam).
- Mouse aiming (rejected by team decision: movement-direction facing).

### Godot concepts learned

- `Input.get_vector()` returns a normalized-with-deadzone Vector2 — no manual normalization needed.
- `Vector2.from_angle(snappedf(dir.angle(), PI/4))` is a compact 8-way snap.
- `@warning_ignore("unused_signal")` silences the per-class warning that misfires on event-bus patterns.
- A `static func` on an autoload triggers a warning when called through the instance — autoload methods should be instance methods.
- `move_and_slide()` uses `velocity` implicitly in Godot 4 (no arguments).
- Tweens created with `create_tween()` are fire-and-forget and auto-free.

### Common mistakes

- Calling `get_tree().reload_current_scene()` mid-physics-callback — defer it (`.call_deferred()`).
- Caching the player in the enemy's `_ready()` can race scene-tree order; a lazy one-time lookup is safer.
- Forgetting that dash i-frames must check the damage *source* — a blanket invulnerability flag would wrongly block self-damage from items.

### Suggested exercises

- Add a second `.tres` (faster, 1-hit enemy) and drop it in the room — zero code should change.
- Change dash_duration in the editor inspector and feel the difference (no recompile).

### References

- godot-standards.md (statics, node access, signals), game-architecture.md (communication rules), PROJECT-CONTEXT.md §4–5.

---

## Session 2026-07-25 (later) — Phase 2 (Bag, Magic Item Framework, Fire Orb)

### Feature

Specs 002 + 003 + 004: the game's core mechanic, end to end.

### What was implemented

- `systems/magic_items/`: MagicItemResource (data) + MagicItem node (state-independent countdown, HELD/THROWN/LANDED, escalating 2→10 Hz blink, wall-aware flight via raycast), polymorphic MagicItemEffect resources (AreaDamageEffect + DamageLingerZone enforcing max 1 hit/target), fire_orb.tres.
- `systems/bag/`: Bag scene (pool resource, uniform random draw, draw-or-throw on a single input, signal relay to EventBus), item_pool.tres.
- Player wiring: Attack → `bag.draw_or_throw(facing)`; kick redirects landed items (+5 tiles) before falling back to enemy damage.
- `tests/smoke_test.tscn`: input-simulated end-to-end test (11 checks, SMOKE PASS).

### Why this architecture?

- **Effects as polymorphic Resources** instead of an effect_type enum + match: adding freeze/knockback later = new subclass + new .tres, base classes untouched (Spec 003's acceptance criterion, and the open/closed principle in practice).
- **Countdown lives in MagicItem, not in the Bag**: the "no safe state" pillar means the timer must be identical across held/thrown/landed — so state changes only move the node, never touch `_elapsed`.
- **Bag never references Player**: it receives `facing` as an argument. Player → Bag is an inward direct call (allowed); Bag → world is signals only.

### Alternatives considered

- Enum + match resolver in the base item (rejected: every new effect edits the base).
- Physics-based thrown item (RigidBody2D) — rejected for a tween + raycast: deterministic, cheap, and landing exactly at 2 tiles matters more than bounce realism for this design.

### Godot concepts learned

- `Input.action_press()/action_release()` lets you simulate player input for automated tests — `is_action_just_pressed` can't tell the difference.
- `Node.reparent(true)` moves a node without popping visually (keeps global transform) — how the held item becomes a world item on throw.
- Typed script Arrays in .tres serialize as `Array[ExtResource("script")]([...])`.
- A GDScript class cache issue: `class_name` scripts created outside the editor need an editor rescan before CLI runs resolve them.
- `is_instance_valid()` + null checks beat stored references for anything that can `queue_free()` mid-frame.

### Common mistakes

- Reading MCP/CLI output after `get_tree().quit()` — capture stdout from the CLI run instead.
- Forgetting the linger zone must also hit targets that *walk in* during the window (not just at trigger) while still capping at 1 hit each.

### Suggested exercises

- Author a `.tres` clone of the Fire Orb with radius_tiles = 3 and watch the Atomic Orb exist with zero code.
- Break the smoke test on purpose (change throw distance) and watch which check fails.

### References

- Spec 002/003/004; PROJECT-CONTEXT §3–4; pillar 1 (countdown pressure) and 4 (friendly fire).

---

## Session 2026-07-25 (Phase 3) — Right Hand of Ursula

### Feature

Spec 005: the second MVP item, and with it the proof that the item framework extends without base-class edits.

### What was implemented

- `FreezeAreaEffect` (new MagicItemEffect subclass) + `right_hand_of_ursula.tres` (4 s activation, 1-tile radius, 5 s movement-only freeze) + both items in `item_pool.tres`.
- `effect_flash.gd`: transient fading circle for instant effects (no class_name; preloaded by path).
- Player freeze tint (blue modulate while frozen, restored on thaw) mirroring the enemy's.
- Smoke test: per-section injected pools (a 2-item random pool would make tests flaky) and 8 new freeze checks — 19 total.

### Why this architecture?

Adding Ursula touched **zero** existing classes: one subclass, one .tres, one pool entry. That was Spec 003's acceptance criterion, now demonstrated. Freeze override semantics (new freeze replaces the running timer) came out of the test design, not the spec — worth remembering that writing tests surfaces unspecified behavior.

### Godot concepts learned

- A tween needs the node inside the tree (`create_tween()` uses `get_tree()`), so transient visuals start their fade in a post-`add_child()` setup call.
- Scripts without `class_name` are still perfectly usable via `preload()` by path — and they sidestep the global class cache entirely.
- Typed arrays built in code (`var a: Array[X] = [...]`) assign cleanly to typed `@export` properties.

### Common mistakes

- A test prop (the second drawn item) landed near the frozen enemy and re-froze it, failing the unfreeze check — test *setups* can create the interference they're testing against. Fixed by moving the enemy clear before the second trigger; frozen position doesn't affect the timer being measured.

### Suggested exercises

- Author `left_hand_of_ursula.tres` conceptually: what would a KnockbackEffect subclass need that FreezeAreaEffect doesn't? (Answer: a direction per target — from item to target.)

### References

- Spec 005; PROJECT-CONTEXT §4 (freeze semantics); pillar 3 (improvisation — two items, two strategies).

---

## Session 2026-07-25 (Phase 4) — Room Flow + HUD

### Feature

Specs 007 + 008 (written first, then coded): room state machine, doors, transitions, health persistence, HUD.

### What was implemented

- `rooms/room.gd`: WAITING (1 s telegraph, enemies inactive) → COMBAT → CLEARED; counts its own enemies via `EventBus.enemy_died`; opens the door; handles the transition (stores health in GameState, `change_scene_to_file`).
- `rooms/door.gd/.tscn`: dumb door — blocker collision + Area2D passage that only reports `player_entered`.
- `ui/hud.gd/.tscn`: 5 hearts (dim on loss) + held-item slot (swatch + name); EventBus-only, no gameplay calls.
- `ui/win_screen.tscn`, `rooms/room_02.tscn` (3 enemies); health persists across rooms via `GameState.player_health`.
- `EventBus.item_drawn` upgraded to carry the full MagicItemResource (UI needs color/name, not just an id).

### Why this architecture?

- The **room owns the flow**; door and enemies stay decision-free. One owner per question ("is combat over?") keeps the count in exactly one place.
- **Health in GameState, not in a persistent player node**: scenes are swapped whole (simple, jam-safe); the autoload carries the one number that must survive. Autoloads hold data, never node references.
- **HUD reads, never writes**: the UI-never-contains-gameplay rule from game-architecture.md, enforced by only connecting to EventBus.

### Godot concepts learned

- `set_deferred("disabled", true)` for collision shapes — flipping physics state inside a physics callback is unsafe.
- `change_scene_to_file` should also be deferred (`.bind(path).call_deferred()`).
- Preloaded scripts (`const X := preload(...)`) work as type annotations — and sidestep the global class cache for fresh classes.
- PowerShell 5.1 `Get-Content` reads ANSI by default: round-tripping UTF-8 docs through it mangles em-dashes (mojibake). Use the file-writing tools, not shell pipes, for docs.

### Common mistakes

- Counting enemies with a group query *at clear time* would count test-spawned/off-room enemies; counting once at `_ready` and decrementing on the death signal keeps ownership clean.

### Suggested exercises

- Add a room_03 with a different enemy layout: duplicate the scene, edit positions and `next_scene_path` — no code.
- Change `telegraph_seconds` in the Inspector and feel how the calm beat changes room pacing.

### References

- Specs 007/008; PROJECT-CONTEXT §3 (loop) e §6 (HUD rules); game-architecture.md (Room states, UI rule).

---

## Session 2026-07-26 — Phase 4.5 (Spec 009: HUD trim + art-ready hooks)

### Feature

Spec 009 MVP scope on branch `feature/hud-special-slots`: HUD trimmed to hearts + held-item box (moved right), bag-pool region removed, art-ready texture hooks with graybox fallback. First session on the Fable model.

### What was implemented

- `ui/hud.tscn`: PoolBox deleted; HeldSlot re-anchored from center (anchors 0.5) to the right edge (anchors 1.0, offsets −240/−20 — mirrors the hearts' 20 px left margin). Added hidden texture twins: `BarBgTex` + `SlotFrameTex` (NinePatchRect) and a `Tex` TextureRect inside each heart.
- `ui/hud.gd`: pool code removed (`_build_pool_slots`, `_make_icon`, `POOL_SLOT_BG`); new `_apply_art()` shows any texture assigned in the editor and hides its graybox stand-in; hearts driven by exported `heart_texture` + `heart_empty_tint`.

### Why this architecture?

- **Graybox fallback via node twins, not code branches per element:** the scene holds both representations; code only toggles visibility once in `_ready()`. Same idiom the held slot already used (`HeldIcon` ColorRect vs `HeldIconTex` TextureRect), so the codebase stays consistent.
- **Editor-first art swap:** Design drops PNGs onto `BarBgTex`/`SlotFrameTex` or the `heart_texture` export — zero code edits (ADR-001 means art must come from the team, so the code side has to be ready before the assets exist).
- **NinePatchRect for bar/frame:** stretches without distorting borders, and margins are tweakable in the Inspector per-texture.

### Alternatives considered

- Exported textures for *everything* on the HUD root: one-stop Inspector panel, but NinePatch margins would then be tuned blind (texture applied only at runtime). Assigning directly on the visible nodes keeps editor preview honest; only the heart texture is a root export because it fans out to 5 nodes.
- Replacing ColorRects with TextureRects outright: loses the graybox fallback the jam still needs.

### Godot concepts learned

- Control anchors: `anchor_left/right = 1.0` + negative offsets pins a fixed-width box to a parent's right edge.
- `NinePatchRect` vs `TextureRect`: 9-patch preserves corner/border pixels when stretching.
- `TextureRect.expand_mode = 1` + `stretch_mode = 5` (keep aspect centered) for icon-in-box rendering.
- `modulate` tinting a white sprite is the cheap full/empty state (no second texture needed).

### Common mistakes

- Forgetting to remove the `@onready` reference when deleting a scene node (`_pool_box`) — boots fine until the `$` lookup throws at runtime; headless `--quit-after` boot catches it.
- Godot MCP `run_project` loses the child process in this environment (`get_debug_output` → "no active process"); verify with headless CLI runs instead.

### Suggested exercises

- Assign a temporary PNG to `BarBgTex` and watch `_apply_art()` hide the graybox; tweak the 9-patch margins in the Inspector.
- Move the HeldSlot to bottom-center again using only anchors/offsets (no code) to internalize the anchor math.

### Late addition (same session): first real HUD art integrated

Design delivered the wooden bar, item container and a 400x400 item spritesheet with a
JSON frame map. Integration touched zero GDScript — proof the hooks worked: textures
assigned on `BarBgTex`/`SlotFrameTex` in hud.tscn, and each item's HUD icon wired as an
`AtlasTexture` sub-resource (atlas = spritesheet, region from the JSON coords) into the
`.tres` `appearance` field the HUD already reads. New concepts: `AtlasTexture` (region
view over a sheet — no image slicing), hand-editing `.tres` ext/sub-resources with
`load_steps`, and scripted screenshot verification (instance the room, emit
`EventBus.item_drawn`, `get_viewport().get_texture().get_image().save_png()`), which
caught that a reported "sprite not showing" was actually the box clearing on throw.

### References

- Godot docs: Control anchors & offsets, NinePatchRect, TextureRect stretch modes, AtlasTexture.

---

## Session 2026-07-27 — Phase 6.5 (Spec 018: Difficulty Levels)

### Feature

Three difficulty levels (Apprentice / Wizard / Archmage) selected after New Game,
scaling enemy pressure and player durability — never the item countdowns.

### What was implemented

- `systems/difficulty/difficulty_resource.gd` + three `.tres` (data-only knobs).
- `GameState.difficulty` defaulting to a preloaded Wizard (= exact prior balance).
- `enemy.gd` computes `applied_move_speed/attack_cooldown/shoot_cooldown/
  detection_tiles` once in `_ready()`; behaviors read those instead of raw stats.
- `player.gd` `max_health()` + i-frame duration from the difficulty (PlayerStats
  keeps base values as fallback/documentation).
- `hud.gd` `_sync_heart_count()` clones the scene's template heart to match max
  health (7 hearts on Apprentice) — art/animation carry over via duplicate().
- `ui/menu/difficulty_select` — same code-driven wooden-button pattern as the
  main menu; hotkeys [1]/[2]/[3]; Wizard pre-selected; ESC backs out.

### Why this architecture?

- **Consumers apply multipliers; shared .tres never mutated.** Godot caches
  loaded resources — writing `stats.move_speed *= x` at spawn would compound
  across every enemy and leak between difficulty changes within a session.
- **Default-Wizard-preload makes difficulty invisible** to every entry path that
  skips the menu (smoke test, direct scene runs) — zero-drift by construction,
  and the smoke test asserts it.
- **A "baseline level" equal to old values** turns a risky balance change into a
  pure addition: normal players literally cannot notice the feature landed.

### Alternatives considered

- Three .tres per *enemy* (easy/normal/hard variants): zero code but a data
  explosion that triples every future enemy's authoring cost.
- Scaling item countdown timers: rejected as a design stance (the countdown is
  the identity; mastery must transfer). Recorded in technical-decisions.md.

### Godot concepts learned

- Resource caching semantics: why runtime mutation of a shared .tres is a trap.
- `preload` in an autoload for a default resource value.
- `Node.duplicate()` clones children + current property state — a scene node as
  a runtime template (HUD hearts).
- `queue_free()` right before `get_tree().quit()` reports as leaked — give the
  tree one frame to process frees in tests.

### Common mistakes

- Letter hotkeys colliding with W/S menu navigation (Wizard's "W") — numbers.
- Forgetting ranged enemies when scaling "attack cooldown" (shoot_cooldown is a
  separate stat; both get the cooldown multiplier).

### Suggested exercises

- Add a fourth "Nightmare" .tres in the editor only (no code) and see it work
  end-to-end by pointing a select row at it — proof the system is data-driven.
- Tune Archmage's multipliers in the Inspector and feel the difference.

### References

- Godot docs: Resource (caching), Node.duplicate, SceneTree.quit.
