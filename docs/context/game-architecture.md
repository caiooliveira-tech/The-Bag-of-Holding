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

---

# Data Ownership

Resources own gameplay values.

Scenes own composition.

Scripts own behavior.

Autoloads own global state.

---

# Performance Rules

Cache node references.

Avoid allocations inside gameplay loops.

Only optimize after gameplay is validated.

## World Scale

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