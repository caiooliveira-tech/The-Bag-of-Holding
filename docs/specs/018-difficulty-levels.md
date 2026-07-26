# Spec 018 - Difficulty Levels (Phase 6.5)

**Status:** Implemented (2026-07-27, branch `feature/difficulty-levels`, PR #4)

Implementation notes vs. the draft: hotkeys on the select screen are [1]/[2]/[3]
(letters would collide with W/S navigation); the HUD syncs the heart count on the
first refresh (player group lookup is lazy), not literally in `_ready()`; flavor
text is placeholder pending Design (open question below).

## Goal

Three selectable difficulty levels — **Apprentice / Wizard / Archmage** (easy /
normal / hard) — chosen at New Game, scaling *enemy pressure* and *player
durability* without touching the item countdowns that define the game.

## Design Stance (team-confirmed direction)

**Item countdown timers never scale with difficulty.** The countdowns are the
game's identity (one-core-mechanic pillar): "Fire Orb = 3 s" is knowledge the
player masters, and that mastery must transfer across difficulties (readability
pillar). Difficulty changes how much pressure enemies apply while the player
solves the same puzzle — it never changes the puzzle.

## Gameplay Description

From the main menu, New Game leads to a difficulty select (same wooden-button
style); the run then plays with that difficulty's knobs applied. Wizard is the
baseline — its values are exactly today's balance, so "normal" players notice
nothing. Apprentice gives more hearts, more forgiving i-frames, and slower/
lazier enemies. Archmage trims hearts and i-frames and makes enemies faster,
more alert, and more relentless.

## Knobs (per level)

| Knob | Apprentice | Wizard | Archmage |
| --- | --- | --- | --- |
| Player max health | 7 | 5 | 4 |
| Post-hit i-frames (G3) | 0.8 s | 0.5 s | 0.25 s |
| Enemy move speed × | 0.7 | 1.0 | 1.15 |
| Enemy attack/shoot cooldown × | 1.25 | 1.0 | 0.8 |
| Enemy detection radius × | 0.8 | 1.0 | 1.2 |

Wizard's multipliers are all 1.0 and its absolute values equal today's
`PlayerStats.tres` — the definition of "no drift".

Tuning log: Apprentice enemy speed 0.85 → **0.7** (playtest 2026-07-27 — at
±15% the three levels' speeds were indistinguishable in play; Archmage left at
1.15 pending the same playtest scrutiny).

## Functional Requirements

- **`DifficultyResource`** (`systems/difficulty/difficulty_resource.gd` + three
  `.tres` next to it): `display_name`, `player_max_health: int`,
  `hit_iframe_duration: float`, `enemy_speed_mult`, `enemy_cooldown_mult`,
  `enemy_detection_mult` (typed floats, defaults = Wizard). Data + validation
  only, no node deps (Resources rule).
- **`GameState.difficulty`** holds the active resource (autoloads own global
  state); defaults to Wizard so every existing entry path (smoke test, direct
  scene runs) behaves exactly as today. Selecting a difficulty sets it before
  the run starts; `reset_run()` does **not** reset it (session keeps the last
  choice as default).
- **Enemies** apply the three multipliers once at `_ready()` on top of their
  `.tres` stats (base `EnemyStats` resources stay untouched — balance work and
  difficulty stay independent). Both archetypes covered: melee (speed, attack
  cooldown, detection) and ranged (speed, shoot cooldown, detection).
- **Player** takes `max_health` and `hit_iframe_duration` from
  `GameState.difficulty` instead of `PlayerStats` when present (PlayerStats
  keeps the base values as documentation + fallback).
- **HUD hearts become count-driven:** the bar currently has exactly 5 heart
  nodes; Apprentice needs 7. `hud.gd` instances heart nodes from the player's
  max health at ready (duplicating the existing heart node as template so the
  art/animation setup is preserved). Presentation-only rule unchanged.
- **Menu:** after New Game, a difficulty select screen (`ui/menu/
  difficulty_select.tscn`) in the established wooden-button + keyboard-nav
  style; ESC returns to the main menu. Buttons show name + a one-line flavor
  description (menu description-panel tone). Selection starts the run.
- Difficulty is run-scoped, in-memory only — no disk persistence (no save
  system yet).

## Architecture

- Scaling is applied by the *consumers* (enemy/player read `GameState.
  difficulty` at ready), not by mutating shared `.tres` resources at runtime —
  mutating them would leak between difficulties within a session (Godot caches
  loaded resources).
- No new EventBus signals needed: difficulty is set before gameplay scenes
  load, never changes mid-run.
- Interacts with Phase 6 D (RunManager): the room *composition* curve stays
  RunManager's job; difficulty stays a stat-multiplier layer on top. If the
  team later wants enemy-count scaling, it becomes a RunManager input, not a
  new system.

## Acceptance Criteria

- Wizard run is byte-identical in behavior to today (smoke test untouched
  values pass — default difficulty is Wizard).
- On Archmage, an enemy's effective speed/cooldowns/detection reflect the
  multipliers (smoke-verifiable by reading the enemy's applied values after
  spawn with a set difficulty).
- On Apprentice, the player spawns with 7 max health and the HUD shows 7
  hearts; on Archmage, 4.
- Countdown timers are identical on all three levels (assert Fire Orb
  activation time unchanged).
- Difficulty select is reachable from New Game, keyboard-navigable, ESC backs
  out; the chosen level survives death/restart within the session.
- Smoke test extended with the above; all checks green.

## Out of Scope

- Enemy *count* / room composition scaling — Phase 6 D (RunManager) territory.
- Difficulty-specific rewards, score multipliers, unlocks.
- Disk persistence of the chosen difficulty (no save system).
- Mid-run difficulty change.
- Item countdown scaling — excluded by design stance above, not deferred.

## Open Questions

- Flavor text per level for the select screen (Design/writing voice — Silas/
  Flavio to provide or bless placeholder).
- Should the pause/death screens display the active difficulty? (Trivial to
  add later; not in this spec.)
