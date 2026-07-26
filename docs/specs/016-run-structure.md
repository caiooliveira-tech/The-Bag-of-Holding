# Spec 016 - Run Structure: 12 Levels in 3 Acts (Phase 6 D)

**Status:** Draft (2026-07-28)

**Revises:** the roadmap's "20-room run". The team's level design (Rafael,
2026-07-28) is **12 levels in 3 acts of 4** — a tighter, fully-authored curve
that fits the jam. The 3-palette / teach-then-escalate shape is unchanged.

## Goal

Replace the hand-built `room_01 → room_02` chain with a **data-driven run**: one
shared level scene configured by a `LevelResource` per floor. Difficulty rises
along two axes the player can *see* — **enemy composition** and **maze
complexity** — and each act introduces one archetype before mixing.

## The Curve

| # | Act / palette | Enemies | Walls |
| --- | --- | --- | --- |
| 1 | **I — blue** | 1 chaser, penned (tutorial) | `PEN` (enclosure) |
| 2 | I | 3 chasers | none |
| 3 | I | 3 chasers | `CROSS` (simple) |
| 4 | I | 5 chasers | `TIC_TAC_TOE` (complex) |
| 5 | **II — pink** | 1 shooter | none |
| 6 | II | 3 shooters | none |
| 7 | II | 3 shooters | `CROSS` |
| 8 | II | 5 shooters | `RING` (complex) |
| 9 | **III — green** | 1 chaser + 1 shooter | none |
| 10 | III | 2 chasers + 2 shooters | `CROSS` |
| 11 | III | 3 chasers + 2 shooters | `RING` |
| 12 | III | 3 chasers + 3 shooters | `TIC_TAC_TOE` (tightest) |

Each act repeats the same rhythm — **meet the archetype → face a group → add a
simple maze → survive the hard mix** — so the player learns a lesson before it
is complicated. Act III combines both archetypes, which is where the maze
matters most: cover from a shooter is a corner a chaser can round.

## Wall Patterns

Generated into the existing paintable `WallTiles` layer (Phase 6A gave those
tiles collision + line-of-sight blocking), so a level's maze is **data, not a
hand-painted scene**:

- **`NONE`** — open arena.
- **`PEN`** — a closed 4×3 enclosure mid-room; the tutorial's isolated enemy.
- **`CROSS`** — a plus-shaped barrier at the center: four approach lanes, easy
  to read, teaches "walls block sight and blasts".
- **`TIC_TAC_TOE`** — two vertical + two horizontal bars forming a `#`: nine
  pockets, many blind corners. The complex pattern.
- **`RING`** — a broken rectangle/diamond ring with gaps between segments:
  circular play, good against kiting shooters.

Rules the generator must respect:

- Never block a door: keep the cells in front of each of the 3 doors clear.
- Never seal the player's spawn or an enemy spawn inside walls (`PEN` is the
  deliberate exception — it pens the *enemy*).
- Patterns are stamped from the room's palette wall tiles (sheet cols 0–5,
  rows 5–7 = one row per palette), so a level's maze matches its act's colors.

## Architecture

- **`LevelResource`** (`systems/run/`): `title`, `palette_row` (0–2),
  `chaser_count`, `shooter_count`, `wall_pattern` (enum), `tutorial_beats`
  (Spec 024). Data + validation only.
- **`run/levels/level_01..12.tres`** — the table above, editable without code.
- **`rooms/level.tscn`** — one shared shell (RoomTiles, WallTiles, border
  collision, 3 Doors, Camera, Player, HUD, ScreenFX) configured at `_ready()`
  from the current `LevelResource`.
- **`RunManager`** (autoload): owns the ordered level list, reads
  `GameState.current_room` as the index, hands the level scene its resource,
  and advances on door transition. Reaching the end of the list → win screen.
- Enemy spawns are computed (ring of positions around the room center, skipping
  cells the pattern occupies), not authored per level — 12 scenes' worth of
  hand-placement would be a maintenance trap for a jam.

Palette also drives the door textures (each palette row has its own
closed/open door tiles), which rooms currently hardcode per scene.

## Interaction With Existing Systems

- **Item pickups (Spec 017)** keep working unchanged: every cleared level offers
  items at its doors.
- **Difficulty (Spec 018)** stays a *global* multiplier; this spec is the
  *designed* curve. Spec 019 (floor-scaled difficulty, parked) is arguably
  redundant now that composition and mazes carry progression — flag for a call.
- **Level title (Spec 022)** comes from `LevelResource.title`.
- `room_01.tscn` / `room_02.tscn` are retired (or kept as smoke-test fixtures —
  see Open Questions).

## Acceptance Criteria

- A run plays levels 1 → 12 in order, each with the composition and maze from
  the table, palette changing per act, and ends on the win screen.
- Every level is completable: no door blocked, no enemy or player spawned inside
  a wall, no unreachable pocket holding the last enemy.
- Adding or reordering a level is a `.tres` edit — no code change.
- Smoke test green, extended with: all 12 resources load; generated patterns
  leave the door cells clear; spawn counts match the data.

## Out of Scope

- Boss encounter / Violet (post-MVP).
- Randomized or procedural level order — the curve is authored on purpose.
- Per-level music, hazards, or props.

## Open Questions

1. **Keep `room_01/02` as test fixtures?** The smoke test instantiates
   `room_01.tscn` today. *Proposal: keep room_01 as a fixture so the test stays
   independent of run data.*
2. **Does Spec 019 (floor-scaled difficulty) still earn its place** now that the
   curve is authored? *Proposal: drop it; revisit only if playtests feel flat.*
3. **Level 12 ending** — straight to the win screen, or a "to be continued"
   beat now that cutscenes exist (Spec 023)?
4. Enemy counts are a first pass — tune after the first full playthrough.
