# Game Architecture

## Folder Structure

```
res://
├── autoloads/        # Global singletons (GameState, EventBus, SaveManager, AudioManager)
├── entities/          # Player, enemies, NPCs — one subfolder per entity, scene + script together
│   └── player/
│       ├── player.tscn
│       └── player.gd
├── systems/           # Cross-cutting gameplay systems (e.g. bag, magic items)
├── resources/         # Custom Resource scripts and .tres data assets, mirrored by system
├── ui/                # HUD, menus, screens
├── levels/            # Rooms / world scenes
├── assets/            # Art, audio, fonts — no scripts
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── shaders/
└── tests/             # Automated test suites
```

Organize by feature, not by node type — a system's scene, script, and resources
live together rather than being split across a global `scripts/` and `scenes/` tree.
Rename/extend top-level folders once real systems are known; the shape above is a
starting default, not a fixed law.

## Scene Tree Philosophy

- Each scene has a single, clear responsibility and can be instanced independently.
- Favor shallow trees; don't nest for the sake of visual grouping alone.
- Composition over inheritance: build features by combining small, reusable
  scenes/nodes rather than deep class hierarchies.
- Don't reach into another scene's internals via long node paths (`$A/B/C`) from
  outside that scene. Expose behavior through the root node's API or signals.

## Autoloads

- Reserve autoloads for true cross-scene, global systems (e.g. `GameState`,
  `EventBus`, `SaveManager`, `AudioManager`). Default to *not* using one.
- Autoloads must not hold hard references to scene-tree nodes that can be freed
  (player, enemies, projectiles) — communicate via signals or method calls instead.
- Prefer a single `EventBus` autoload for decoupled cross-system communication
  over autoloads calling each other directly.

## Resources

- Use custom `Resource` scripts for data that should be tunable without touching
  code (item stats, enemy stats, level configs).
- Resources hold data and validation only — no scene-tree or node dependencies.
- Store `.tres` instances under `resources/`, mirroring the system that consumes them.

## Signals

- Signals flow outward ("I changed"); direct calls flow inward ("do this").
- Name signals as past-tense events (`health_depleted`, `item_collected`), not commands.
- Avoid signal chains more than two hops deep — if a signal is just being
  re-emitted up several layers, route it through the `EventBus` instead.

## State Machines

- Any node with more than ~3 mutually exclusive behavior modes uses an explicit
  state machine, not a bundle of booleans or a single sprawling `match`.
- Prefer small state objects/scripts with `enter()`, `exit()`, `process()` over
  one giant conditional.

## Save System

- Save/load through Resource serialization (`ResourceSaver` / `ResourceLoader`),
  not hand-rolled string or JSON parsing, unless a specific need forces otherwise.
- Every save-relevant Resource carries a `save_version` field so future saves
  can migrate old data instead of breaking on it.

## Performance Rules

- Cache node references in `_ready()`; never call `get_node()`/`$` inside
  `_process()` or `_physics_process()`.
- Prefer signals over per-frame polling for state changes.
- Pool objects that are spawned/destroyed at high frequency (projectiles, VFX)
  instead of repeated `instantiate()`/`queue_free()`.
- Profile before optimizing — don't hand-optimize without the Godot profiler
  showing an actual hotspot.

## Architectural Invariants

- Autoloads never hold hard references to freed/freeable scene nodes.
- Gameplay systems never reach into another node's internals directly across
  scene boundaries; they communicate via signals or a shared autoload.
- No scene reaches "up" past its own root to modify a parent or sibling scene.
