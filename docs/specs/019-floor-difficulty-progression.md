# Spec 019 - Floor-Based Difficulty Progression (Phase 6.6)

**Status:** Draft (2026-07-27)

**Supersedes:** Spec 018's *selection mechanism* (the difficulty select screen is
removed). Spec 018's *infrastructure* — `DifficultyResource`, `GameState.difficulty`,
enemies' `applied_*` stats at spawn, the HUD's count-driven hearts — is reused as-is.

## Goal

Difficulty is no longer chosen by the player: it **grows as Shoelace climbs the
tower**. Each floor (room) maps to a difficulty tier; the same enemy types repeat
across floors but arrive buffed — faster, more alert, more relentless — so the climb
gets ever harder. New Game goes straight into the run.

## Design Rationale (Rafael, 2026-07-27)

With the 20-room run coming (Phase 6 D), a menu choice is redundant: the tower
itself is the difficulty curve. Repeating enemy types with buffs also multiplies
content cheaply — one grunt + one shooter become many encounters that *feel*
different by floor.

Unchanged stances:
- **Item countdowns never scale** (technical-decisions.md, 2026-07-27) — by floor
  or by anything else.
- **Player durability does not shrink with altitude:** max health stays 5 and
  post-hit i-frames stay 0.5 s for the whole run. Only *enemy pressure* climbs.
  (Mechanically: tier resources simply keep the same player values, so no code
  special-case is needed; the HUD heart count never changes mid-run.)

## Progression Model

- **An ordered array of `DifficultyResource` tiers** indexed by floor
  (`GameState.current_room`), clamped to the last tier — floors beyond the array
  reuse the final tier, so adding floors never breaks.
- The existing three `.tres` are repurposed as the first tiers (renamed
  conceptually: tier_1/2/3 — files may keep their names or be renamed in
  implementation); more tiers (tier_4, tier_5 …) are pure data additions with
  ever-stronger enemy knobs.
- `GameState.difficulty` becomes a **getter** over `current_room` — one source of
  truth; enemies keep reading it at spawn with zero changes.
- When RunManager (Phase 6 D, Spec 016) lands, the tier array naturally migrates
  into its per-room data — this spec is designed to be absorbed by D, not to
  fight it.

## Knobs per tier (proposal — tune in review)

| Knob | Floor 1 | Floor 2 | Floor 3+ (until D adds floors) |
| --- | --- | --- | --- |
| Enemy move speed × | 0.85 | 1.0 | 1.15 |
| Enemy attack/shoot cooldown × | 1.15 | 1.0 | 0.85 |
| Enemy detection radius × | 0.9 | 1.0 | 1.2 |
| **Enemy bonus hits** (new knob) | +0 | +0 | +1 |

- **`enemy_bonus_hits: int`** is added to `DifficultyResource` (default 0): flat
  extra hits on top of each enemy's `max_hits` — the tangible "buffed enemy"
  feel (a floor-3 grunt takes 3 hits, not 2). Applied at spawn like the other
  knobs; damage-tint math uses the applied total.
- Floor 1 is gentler than today's baseline (it's the tutorial beat); floor 2 is
  the old Wizard exactly; floor 3+ is the old Archmage plus a bonus hit.
- Player fields in every tier: max_health 5, i-frames 0.5 (constant by design).

## What is removed

- `ui/menu/difficulty_select.*` — deleted. Main menu New Game → `room_01`
  directly (reset_run stays in the New Game action).
- The "difficulty choice survives death/restart" behavior — moot; the curve is
  positional. Death still restarts the current room; the floor's tier reapplies.

## Functional Requirements

- `GameState`: progression array (exported/preloaded tier list) +
  `difficulty` as a read-only getter of `current_room`; `reset_run()` unchanged.
- `DifficultyResource`: add `enemy_bonus_hits: int = 0`.
- `enemy.gd`: `hits_remaining`/tint math use `stats.max_hits +
  difficulty.enemy_bonus_hits` (applied once at `_ready()`, same pattern).
- Main menu: New Game → room_01 (difficulty select scene deleted).
- Smoke test: Section 10 reworked — drive `current_room` instead of assigning
  `difficulty`; assert floor-2 = exact old baseline (zero drift anchor), floor-3
  multipliers + bonus hit, clamp beyond the array, countdown invariance.

## Acceptance Criteria

- Floor 2 (room_02) plays with the exact pre-difficulty baseline values.
- Room 1 enemies are measurably gentler; a hypothetical room 3+ enemy is faster,
  more alert, and takes one extra hit.
- Beyond the last tier, values clamp (no crash, no runaway scaling).
- New Game skips any difficulty menu; countdowns identical on every floor.
- Smoke green.

## Out of Scope

- Per-room enemy *composition* (which/how many enemies) — RunManager (Spec 016).
- Endless/formula-based scaling — the run is a designed 20-floor climb; tiers
  stay authored data. Revisit only if an endless mode is ever wanted.
- Difficulty-related UI (floor indicator etc.) — possible Phase 6 D territory.

## Open Questions

1. Tier values above (esp. floor 1 gentleness and where +1 bonus hit starts) —
   first-pass numbers, tune in playtest.
2. `enemy_bonus_hits` — confirm the team wants HP buffs at all (it changes
   kick-kill counts: a buffed grunt survives two kicks).
3. Keep the three existing `.tres` filenames (apprentice/wizard/archmage) or
   rename to `tier_01.tres` … now that they're floors, not choices? (Proposal:
   rename — the old names imply player choice.)
