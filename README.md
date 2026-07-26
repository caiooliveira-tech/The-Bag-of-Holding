# The Bag of Holding

A top-down action game built in **Godot 4.7**, where a bottomless bag of magic items is your entire arsenal — and your biggest liability. Every item you pull is both an opportunity and a risk, and a ticking countdown keeps you moving.

> 🎮 **Playable.** The full loop is in: menus, difficulty levels, tiled rooms, four magic items, two enemy archetypes, audio, and a juice pass. See [Status](#status).

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
├── autoloads/             # EventBus, GameState, AudioManager, Juice
├── entities/              # Player, enemies, projectiles (scene+script+.tres together)
├── systems/               # Bag, magic items, difficulty, juice
├── rooms/                 # Room scenes, tiles, doors
├── ui/                    # HUD, menus (main/options/credits/pause/death), screen FX
├── assets/                # Art (UI, fonts) — no generative AI assets (ADR-001)
├── tests/                 # Automated smoke test (41 checks)
└── docs/                  # Design & development documentation
    ├── CLAUDE.md          # Working agreement for AI-assisted development
    ├── context/           # Game vision, architecture, standards, roadmap
    ├── decisions/         # Architecture Decision Records (ADRs)
    └── specs/             # Per-feature specifications (001-018)
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

| Phase | Focus | State |
|-------|-------|-------|
| 0–1 | Foundation, player, first enemy | ✅ |
| 2–3 | Bag system, magic item framework, Fire Orb, Right Hand of Ursula | ✅ |
| 4 / 4.5 | Rooms, doors, HUD (+ art integration) | ✅ |
| 4.6 | Game feel / juice pass (shake, hitstop, i-frames…) | ✅ |
| 6 A–B | Maze walls + line of sight, ranged enemy + projectiles | ✅ |
| 6.5 | Difficulty levels (Apprentice / Wizard / Archmage) | ✅ |
| 6 C | Smart chaser (steering, separation, telegraphed lunge) | ✅ |
| 6 E | Full 6-item catalog + item choice at doors | 🔄 in review |
| 6 D | 20-room run (RunManager) | ⏳ |
| 5 | Ship: export + itch.io | ⏳ |

See [`docs/context/implementation-roadmap.md`](docs/context/implementation-roadmap.md) for the full plan.

## Status

Playable end-to-end: main menu → difficulty select → tiled combat rooms → win/death screens, with 6 magic items (Fire Orb, both Hands of Ursula, Troy, Atomic Orb, Magnetic Horseshoe), item pickups at cleared-room doors, smart melee + ranged enemies, walls with line-of-sight, audio, and a full game-feel pass. Specs 001–015, 017–018, 020–021 implemented; next up is the 20-room run (Phase 6 D). Track live progress in [`docs/context/progress-tracker.md`](docs/context/progress-tracker.md).
