# Spec 020 - Magnetic Horseshoe

**Status:** Draft (2026-07-27)

## Goal

Fifth catalog item (design doc: cartoon magnet, TIME 6 s), completing the crowd-
control trio: freeze stops, knockback scatters, **magnet gathers and pins**.

## Design (from the design doc, jam-simplified)

On trigger, the horseshoe yanks the **two nearest enemies** rapidly to its
position and **pins them there indefinitely** — stuck to the magnet, they can
still attack and still take damage, but cannot move independently. The design
doc's "fixes itself to an enemy ≥ 2 tiles away" is simplified to a **pull radius
of 3 tiles** centered on the item (interpretation flagged below).

Strategy: gathering two enemies onto one spot makes them a single AoE target —
magnet + any damage item is the game's first deliberate combo.

## Functional Requirements

- `MagnetAreaEffect` (new `MagicItemEffect` subclass — base framework untouched,
  same as Specs 005/011): on execute, find up to 2 nearest enemies within
  3 tiles (line-of-sight rule applies, `wall_blocks` like other areas).
- Pulled enemies tween quickly (kick-speed feel) to the trigger position, then
  are **pinned**: movement locked indefinitely (reuse the freeze movement-lock
  path with `INF`-style duration or a dedicated `pin()` — implementation
  detail), still attacking, still damageable.
- Pin persists until the enemy dies; room clear ends the room anyway.
- Magnet visual stays at the spot while any pinned enemy lives (readability).
- `activation_time_seconds = 6.0` (longest countdown yet — high risk, high
  control). Countdown/blink/throw/kick behavior inherited unchanged.
- `.tres` with `id = &"magnetic_horseshoe"`; graybox color (suggest steel gray)
  — **no sheet icon exists yet; Design to deliver** (HUD falls back to swatch).

## Acceptance Criteria

- Two enemies inside the radius get dragged to the magnet point and stop
  pathing; a third stays free. Pinned enemies still attack when in range and
  still take damage/die.
- Frozen-vs-pinned don't conflict (freeze on a pinned enemy just keeps it in
  place; thaw doesn't unpin).
- Smoke: pull gathers two enemies to the point; third unaffected; pinned enemy
  killable.

## Out of Scope

- Pinning the *player* (design doc pins characters; jam scope: enemies only —
  flagged below).
- Magnet-follows-enemy variant from the doc's first sentence.

## Open Questions

1. **Interpretation check (team):** doc says the magnet "fixes itself to an
   enemy" then drags the two nearest to it. This spec anchors the pin at the
   item's landing spot instead — simpler and more readable. OK?
2. Should the player also be pullable/pinnable (friendly-fire pillar says our
   items hurt us — does "control" count)? Proposal: enemies only for now.
3. Icon needed from Design (sheet slot).
