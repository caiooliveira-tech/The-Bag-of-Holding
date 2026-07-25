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
