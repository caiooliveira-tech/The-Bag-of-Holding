# Glossary

## Gameplay & Project Terms

### Vertical Slice

A playable version containing all systems required for one gameplay experience.

### Playable Build

A version that can be tested by another player.

### Graybox

Prototype using primitive graphics.

Used to validate mechanics before art production.

### Stretch Goal

A feature implemented only if the MVP is complete.

### MVP

Minimum playable version required for submission.

### Bag

System responsible for drawing random magic items.

### Held Item

Current item carried by the player.

Countdown already started.

### Activation Time

Time between drawing an item and its activation.

### Friendly Fire

Player can be affected by their own magic items.

### Power Tier

Damage classification.

- Light
- Medium
- Heavy

### EventBus

Central event dispatcher used to reduce coupling.

### Resource

Godot asset containing configurable gameplay data.

### State Machine

Object responsible for controlling exclusive gameplay states.

## Godot & Engine Terms

- **Node** — the base building block of a scene; has a specific type/behavior
  (e.g. `Node2D`, `CharacterBody2D`, `Area2D`).
- **Scene** — a tree of nodes saved as a `.tscn` file; can be instanced like a prefab.
- **PackedScene** — the serialized, instanceable form of a scene (the `.tscn`/`.scn` resource).
- **Autoload / Singleton** — a scene or script loaded globally at startup, accessible
  from anywhere without an explicit reference.
- **Signal** — a typed event a node emits; other nodes connect callbacks to react to it.
- **Resource** — a serializable data object (`.tres`/`.res`); used for config and
  data-driven assets, not scene-tree behavior.
- **Instancing** — creating a live copy of a `PackedScene` in the running scene tree.
- **Scene Tree** — the runtime hierarchy of all active nodes.
- **State Machine** — a pattern for modeling mutually exclusive behavior modes
  with explicit transitions, instead of scattered boolean flags.
- **Tween** — an object that animates a property over time (position, scale, alpha, ...).
- **Viewport** — a rendering surface; can represent the main game view or an
  off-screen render target.
