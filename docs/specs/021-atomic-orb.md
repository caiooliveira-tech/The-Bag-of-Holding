# Spec 021 - Atomic Orb

**Status:** Draft (2026-07-27)

## Goal

Sixth catalog item (design doc: fire lamp with the atomic symbol, TIME 5 s):
the Fire Orb's big sibling — **heavy damage, 3-tile radius, 2 s linger**. The
game's scariest friendly-fire moment: a blast that covers a third of the room.

## Design

Pure data on the existing `AreaDamageEffect` — zero new code expected:

| | Fire Orb (Spec 004) | **Atomic Orb** |
| --- | --- | --- |
| Countdown | 3 s | **5 s** |
| Damage tier | Medium (2 hits) | **Heavy (3 hits)** |
| Radius | 1 tile | **3 tiles** |
| Linger | 1 s | **2 s** |

- Linger keeps the established cap rule (max 1 extra hit per target — the
  2026-07-25 Fire Orb decision generalizes; flagged below for confirmation).
- Line-of-sight/`wall_blocks` applies as with every area effect.
- `.tres` with `id = &"atomic_orb"`, `activation_time_seconds = 5.0`; graybox
  color (suggest toxic green) — **no sheet icon yet; Design to deliver**.
- Explosion feel: reuse the G1/G4 juice (bigger `expanding_ring` + stronger
  shake at the same trauma pattern; no new systems).

## Acceptance Criteria

- Detonation deals 3 hits within 3 tiles (kills a base grunt outright), blocked
  by walls, and can hit the player (never blocked by i-frames — pillar 4).
- Linger zone persists 2 s and deals at most 1 additional hit per target.
- Smoke: heavy blast kills a full-health grunt in the open; wall blocks it;
  radius ≈ 3 tiles verified by an in/out placement pair.

## Out of Scope

- Screen-wide vignette/flash unique to this item (juice polish, later).
- Icon (Design).

## Open Questions

1. Confirm the linger cap generalizes (1 extra hit per target max) — or should
   the Atomic linger be nastier (e.g. 2 ticks)? Proposal: same cap, keep rules
   uniform.
2. 3-tile radius on a ~11-tile-tall room is huge — tune down to 2.5 if
   playtests read as unfair? First pass ships per the design doc.
