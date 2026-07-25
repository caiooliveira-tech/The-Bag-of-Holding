# Godot Standards

## Engine

- Godot 4.7
- GDScript only
- Forward+

---

# Coding Principles

- Static typing everywhere
- Composition over inheritance
- One responsibility per script

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

snake_case

Methods

snake_case()

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

# State Machines

Required for complex gameplay.

Avoid boolean explosions.

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