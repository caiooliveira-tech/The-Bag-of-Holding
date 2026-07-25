# Spec 006 - Basic Enemy

**Status:** Implemented (2026-07-25)

## Goal

Implement the shared MVP enemy: a parameterized approach-and-attack melee unit, so ranged vs. melee later becomes a data difference (EnemyStats), not new code.

## Gameplay Description

The enemy idles until the player enters its detection radius (~5 tiles), then chases and attacks in melee range. It takes discrete hits, flashes red on damage, darkens as it nears death, and disappears on death. It supports a movement-only freeze (for Right Hand of Ursula, Spec 005).

## Functional Requirements

- Proximity detection only (default 5 tiles = 160 px); no line-of-sight checks (team decision).
- Chase: move directly toward the player while detected and outside attack range.
- Attack: melee hit for 1 damage on a cooldown while in range (~1 tile).
- Health: discrete hit count via EnemyStats.max_hits (MVP default: 2).
- All tunables (speed, ranges, cooldown, damage, hits) on an EnemyStats Resource.
- Freeze support: `freeze(duration)` locks movement only — a frozen enemy still attacks and still takes damage (decided 2026-07-25).
- Feedback per art-direction.md: white flash on hit, progressively darker tint as hits run out, no HP bar; disappears on death.
- Emits `died` locally and `EventBus.enemy_died(enemy)` globally (room-clear logic, Phase 4, listens there).

## Scene Structure

`entities/enemies/enemy.tscn` — CharacterBody2D root, graybox Polygon2D visual, CollisionShape2D.

## Scripts

- `enemy.gd` — detection/chase/attack/freeze + damage intake

## Signals

- `died`
- `damage_taken(amount)`

## Resources

- `EnemyStats` — move_speed, detection_radius_tiles, attack_range_tiles, attack_cooldown, damage, max_hits
- `melee_grunt.tres` — MVP instance

## Acceptance Criteria

- Enemy ignores the player outside 5 tiles, chases inside it.
- Attacks deal 1 hit on cooldown; player blink confirms damage.
- Dies after max_hits hits, with escalating damage tint before death.
- `freeze()` stops movement but not attacks.

## Test Cases

- Player outside 5 tiles → enemy stands still.
- Player inside radius → enemy chases and attacks in range.
- Two kicks (1 dmg each) kill a 2-hit enemy.
- Frozen enemy in range keeps attacking but does not move.

## Out of Scope

- Ranged archetype (data variant later, if time allows)
- Patrol patterns / per-room variation
- Reaction to landed items
