# Spec 015 - Smart Chaser (Phase 6C)

**Status:** Implemented (2026-07-26)

## Goal

Replace the magnet chaser with a readable, less exploitable melee AI:
separation (no clumping), a bit of flanking, wall-aware steering, and a
**telegraphed lunge** instead of instant contact damage. All parameterized.

## Behaviour

- **Steering (CHASE):** move toward the player, blended with
  - **separation** — push away from nearby enemies so they don't stack,
  - **strafe** — a small perpendicular component (per-enemy side) so they arc
    in instead of funnelling straight,
  - **wall avoidance** — if a wall is right ahead, steer toward the open side
    (mitigates getting stuck behind maze walls; full pathfinding is out of scope).
- **Telegraphed lunge attack:** a mini state machine —
  `CHASE → WINDUP (pause + telegraph) → LUNGE (fast committed dash, contact
  damage once) → RECOVER (cooldown) → CHASE`. Entered when the player is within
  `lunge_range` and off cooldown. WINDUP/LUNGE/RECOVER run to completion even if
  the player breaks line of sight (a committed attack is dodgeable, not cancel-able).
- Freeze still cancels movement (no lunge while frozen); knockback still applies.

## Parameters (EnemyStats)

`separation_radius_tiles`, `separation_weight`, `strafe_weight`,
`lunge_range_tiles`, `lunge_windup`, `lunge_speed`, `lunge_duration`,
`lunge_recover`. Ranged archetype (Spec 014) is unchanged.

## Acceptance Criteria

- Two chasers converging on the player don't overlap (separation).
- A chaser winds up (visible pause) before lunging; the lunge deals one hit on
  contact and then recovers.
- A chaser blocked by a wall steers around it instead of pressing into it.

## Out of Scope

- Navigation-mesh pathfinding (steering only).
- Per-room behaviour presets (RunManager/Phase D may add stat variants).
