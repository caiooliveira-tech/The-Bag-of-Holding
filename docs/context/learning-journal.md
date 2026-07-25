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
