# Godot Standards

## Engine

- Godot 4.7
- GDScript only
- Forward+

---

# Coding Principles

- Static typing everywhere (`var health: int = 100`, typed function signatures)
- Composition over inheritance
- One responsibility per script
- Comment why, not what
- Avoid magic numbers — prefer Resources and exported variables

---

# Script Size

Soft limit:

250 lines.

Split responsibilities instead of creating giant scripts.

---

# Naming

Scenes

PascalCase.tscn

Scripts

snake_case.gd

Resources

snake_case.tres

Signals

snake_case (past-tense events, e.g. `health_depleted`)

Methods

snake_case()

Classes and node names

PascalCase (`class_name Player`)

---

# Folder Organization

Organize by feature, not by node type — a system's scene, script, and resources
live together (see `game-architecture.md#folder-structure`).

---

# Exported Variables

Never hardcode gameplay values.

Always expose balancing through Resources or @export.

---

# Node Access

Cache references during _ready().

Never search nodes every frame.

---

# Signals

Signals announce events.

Methods execute actions.

Avoid signal chains longer than two hops.

---

# Autoloads

Treat autoloads as a last resort; default to passing dependencies explicitly.

Reserve them for true cross-scene systems (GameState, EventBus).

---

# State Machines

Required for complex gameplay.

Avoid boolean explosions.

---

# Spec-Driven Workflow

Every feature has a spec under docs/specs/ before implementation.

Reference the spec ID (e.g. `Spec 001`) in commit messages and PR titles.

---

# Jam Development Rules

Optimize for development speed.

Readable code is more important than perfect abstractions.

Small duplication is acceptable.

Premature optimization is discouraged.

---

# Commit Rules

Every commit should:

- compile
- be playable
- avoid broken features

Never leave the main branch unusable.

---

# Graybox Policy

Placeholder graphics are expected.

Gameplay validation always comes before art integration.
