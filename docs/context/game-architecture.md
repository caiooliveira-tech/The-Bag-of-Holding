# Game Architecture

## Philosophy

This project prioritizes gameplay iteration over architectural complexity.

The architecture exists to accelerate development during a Game Jam.

Whenever architecture conflicts with iteration speed,
prefer the simpler solution.

---

# Core Principles

- Composition over inheritance
- Feature-oriented folders
- Event-driven communication
- Data-driven gameplay
- Small reusable scenes
- Graybox first
- Vertical slices

---

# Vertical Slice Philosophy

Every implementation phase must produce a playable build.

Never build isolated backend systems for multiple days.

Correct:

Player
↓

Enemy
↓

Damage
↓

Playable

Wrong:

Player

↓

Inventory

↓

Resources

↓

Signals

↓

Data Layer

↓

Finally test gameplay

Gameplay is always validated first.

---

# Folder Structure

```
res://
├── autoloads/         # Global singletons (EventBus, GameState)
├── entities/          # Player, enemies — one subfolder per entity, scene + script + .tres together
│   ├── player/
│   └── enemies/
├── systems/           # Cross-cutting gameplay systems (bag, magic_items), data .tres included
├── rooms/             # Room scenes, room/door scripts
├── ui/                # HUD, menus, screens
├── tests/             # Automated smoke/integration test scenes
└── docs/              # Context docs, specs, ADRs
```

Organize by feature, not by node type — a system's scene, script, and resources
live together rather than being split across a global `scripts/` and `scenes/` tree.
Rename/extend top-level folders as new systems appear (e.g. `assets/` once final
art/audio lands); the shape above reflects the repo today.

---

# High-Level Systems

Player

Responsible for:

- Movement
- Dash
- Facing
- Input

Bag

Responsible for:

- Random draw
- Hold
- Throw
- Countdown

Magic Item Framework

Responsible for:

- Activation
- Effect execution
- Timers

Enemy

Responsible for:

- Movement
- Attack
- Damage

Room

Responsible for:

- Enemy spawning
- Door control
- Progression

UI

Responsible only for presentation.

Never contains gameplay logic.

---

# Scene Tree Philosophy

- Each scene has a single, clear responsibility and can be instanced independently.
- Favor shallow trees; don't nest for the sake of visual grouping alone.
- Composition over inheritance: build features by combining small, reusable
  scenes/nodes rather than deep class hierarchies.
- Don't reach into another scene's internals via long node paths (`$A/B/C`) from
  outside that scene. Expose behavior through the root node's API or signals.

---

# Communication Rules

Signals communicate events.

Direct calls execute actions.

Never create circular dependencies.

Preferred flow

Player

↓

Bag

↓

Magic Item

↓

EventBus

↓

Enemy

↓

UI

Signal guidelines:

- Signals flow outward ("I changed"); direct calls flow inward ("do this").
- Name signals as past-tense events (`health_depleted`, `item_collected`), not commands.
- Avoid signal chains more than two hops deep — if a signal is just being
  re-emitted up several layers, route it through the `EventBus` instead.

---

# Autoloads

- Reserve autoloads for true cross-scene, global systems (e.g. `GameState`,
  `EventBus`). Default to *not* using one.
- Autoloads must not hold hard references to scene-tree nodes that can be freed
  (player, enemies, projectiles) — communicate via signals or method calls instead.
- Prefer a single `EventBus` autoload for decoupled cross-system communication
  over autoloads calling each other directly.

---

# Resources

- Use custom `Resource` scripts for data that should be tunable without touching
  code (item stats, enemy stats, level configs).
- Resources hold data and validation only — no scene-tree or node dependencies.
- Store `.tres` instances next to the system that consumes them.

---

# State Machines

Use state machines whenever an object has more than three exclusive behaviors.

Player

- Idle
- Move
- Dash
- Holding

Enemy

- Idle
- Chase
- Attack
- Frozen

Room

- Waiting
- Combat
- Cleared

Prefer small state objects/scripts with `enter()`, `exit()`, `process()` over
one giant conditional once states grow beyond an enum's comfort.

---

# Data Ownership

Resources own gameplay values.

Scenes own composition.

Scripts own behavior.

Autoloads own global state.

---

# Save System

- Save/load through Resource serialization (`ResourceSaver` / `ResourceLoader`),
  not hand-rolled string or JSON parsing, unless a specific need forces otherwise.
- Every save-relevant Resource carries a `save_version` field so future saves
  can migrate old data instead of breaking on it.

---

# Performance Rules

- Cache node references in `_ready()`; never call `get_node()`/`$` inside
  `_process()` or `_physics_process()`.
- Prefer signals over per-frame polling for state changes.
- Pool objects that are spawned/destroyed at high frequency (projectiles, VFX)
  instead of repeated `instantiate()`/`queue_free()`.
- Avoid allocations inside gameplay loops.
- Profile before optimizing — don't hand-optimize without the Godot profiler
  showing an actual hotspot. Only optimize after gameplay is validated.

---

# Architectural Invariants

- Autoloads never hold hard references to freed/freeable scene nodes.
- Gameplay systems never reach into another node's internals directly across
  scene boundaries; they communicate via signals or a shared autoload.
- No scene reaches "up" past its own root to modify a parent or sibling scene.

---

# World Scale

Base Tile Size

32 x 32 px

Gameplay measurements

1 tile = 32 pixels

Movement is free.

Tiles are used only as measurement units and level construction units.

Examples

Explosion Radius = 1 tile = 32 px

Throw Distance = 2 tiles = 64 px

Enemy Detection = 5 tiles = 160 px
