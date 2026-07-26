# Spec 014 - Ranged Enemy + Projectile (Phase 6B)

**Status:** Implemented (2026-07-26)

## Goal

A second enemy archetype whose main trait is ranged attack: it keeps its
distance from the player and fires a projectile on a cooldown. Introduces the
projectile system.

## Gameplay Description

The ranged shooter kites — approaches if the player is far, backs off if the
player is too close, holds at a preferred distance and shoots. Its shot is the
sheet projectile (160,0); it flies straight toward where the player was, damages
the player on contact, and is stopped by walls (like vision/explosions, Phase 6A).

## Functional Requirements

- **Projectile** (`entities/projectiles/enemy_projectile`): an Area2D that flies
  in a fixed direction at `speed`, deals 1 hit to the player on contact, despawns
  on hitting a wall (collision layer 1) or after `lifetime`. Sprite = AtlasTexture
  (160, 0, 32, 32). In group `projectiles` so the player's dash/i-frames treat it
  as enemy damage (pillar 4 unchanged: own items still bypass i-frames).
- **Ranged behaviour** on the shared enemy (`stats.is_ranged`): while it can see
  the player (LoS), kite to `preferred_distance_tiles` (approach / back off /
  hold) and fire on `shoot_cooldown`. No line of sight → no fire.
- Reuses the existing detection radius + `_can_see_player()`.
- Firing plays `shot.mp3` via a new `EventBus.enemy_shot`.

## Architecture

- `EnemyStats` gains `is_ranged`, `preferred_distance_tiles`, `shoot_cooldown`.
- `enemy.gd` branches on `is_ranged`: kite+shoot vs. the existing chase+melee.
  (Phase C will deepen the chaser; the ranged branch lands here.)
- `enemy2.tscn` becomes the ranged shooter (`ranged_shooter.tres`); `enemy1`
  stays the melee chaser.
- Player damage gate widened: a source in `enemies` OR `projectiles` counts as
  enemy damage (so dash/i-frames block the shot; own items never do).

## Acceptance Criteria

- A ranged enemy holds its distance and fires; the shot travels and damages the
  player on hit.
- A shot is stopped by a wall between shooter and player.
- Dashing through a shot takes no damage; standing in it does.

## Out of Scope

- Homing/leading shots (straight fire only).
- Multiple projectile types (one shot for MVP).
