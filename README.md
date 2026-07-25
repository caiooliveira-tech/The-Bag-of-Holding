# The Bag of Holding

A top-down action game built in **Godot 4.7**, where a bottomless bag of magic items is your entire arsenal — and your biggest liability. Every item you pull is both an opportunity and a risk, and a ticking countdown keeps you moving.

> ⚠️ **Early development.** The project is in initial setup. Gameplay is spec'd out in `docs/` but not yet implemented — see [Status](#status).

## Gameplay Pillars

1. **Countdown drives strategy** — you're always racing a clock.
2. **Randomness creates emergent gameplay** — what you draw shapes each run.
3. **Every magic item is both opportunity and risk.**
4. **Positioning is more important than reflexes.**
5. **Systems should interact naturally** rather than being scripted set-pieces.

## Tech Stack

| | |
|---|---|
| Engine | Godot 4.7 (Forward+ renderer) |
| Physics | Jolt Physics (3D) |
| Rendering backend | Direct3D 12 (Windows) |
| Language | GDScript |

## Getting Started

### Prerequisites

- [Godot 4.7](https://godotengine.org/download) or newer (standard build; no C#/.NET required)

### Run the project

1. Clone the repository:
   ```bash
   git clone <repo-url> "The-Bag-of-Holding"
   ```
2. Open Godot, click **Import**, and select the `project.godot` file in the project root.
3. Press **F5** (or the Play button) to run.

## Project Structure

```
The-Bag-of-Holding/
├── project.godot          # Engine configuration
├── icon.svg               # Project icon
└── docs/                  # Design & development documentation
    ├── CLAUDE.md          # Working agreement for AI-assisted development
    ├── context/           # Game vision, architecture, standards, roadmap
    ├── decisions/         # Architecture Decision Records (ADRs)
    └── specs/             # Per-feature specifications
```

## Development Approach

This project is developed with a **documentation-first, spec-driven workflow** — as much a learning exercise in Godot architecture as it is a game. Every gameplay feature gets its own spec before implementation, architectural decisions are captured as ADRs, and progress is tracked in `docs/context/`.

Coding conventions (see [`docs/context/godot-standards.md`](docs/context/godot-standards.md)):

- Composition over inheritance
- One responsibility per script; keep scripts under ~250 lines
- Prefer `Resource`s for configuration and exported variables over magic numbers
- Use signals instead of tight coupling
- Comment *why*, not *what*

## Roadmap

| Phase | Focus |
|-------|-------|
| 1 | Project setup, input, player movement, camera |
| 2 | Enemy framework, health, damage |
| 3 | Bag system, magic item framework |
| 4 | Fire Orb (first item) |
| 5 | Remaining magic items |
| 6 | Rooms |
| 7 | Polish |

See [`docs/context/implementation-roadmap.md`](docs/context/implementation-roadmap.md) for the full plan.

## Status

Not started — foundational documentation is in place; the first spec ([Player Controller](docs/specs/001-player-controller.md)) is next. Track live progress in [`docs/context/progress-tracker.md`](docs/context/progress-tracker.md).
