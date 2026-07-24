# Glossary

Document gameplay, programming and Godot terminology.

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

## Gameplay Terms

To be filled in as gameplay specs define them (e.g. "Bag of Holding", "Magic Item").
