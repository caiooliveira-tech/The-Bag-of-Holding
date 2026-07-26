# Spec 017 - Item Choice at Doors (Phase 6 E)

**Status:** Draft (2026-07-27)

**Depends on:** Specs 020 (Magnetic Horseshoe) + 021 (Atomic Orb) — the full
6-item catalog exists before doors start distributing it.

## Goal

The run becomes a build: the Bag's pool **starts with only the Fire Orb**, and
every cleared room offers new items at its doors — walking through a door adds
that door's item to the pool from that moment on. The arsenal (and the risk
profile) grows with the climb.

## Rules (team-answered, 2026-07-27)

- **Offer pool = the full catalog** (all 6 items). Each open door shows one
  item; offers are **distinct across the room's doors** (sampled without
  replacement per room).
- **Duplicates are allowed and intentional:** a door may offer an item the
  player already owns. Picking it **does nothing** (no double-weighting) — an
  owned-item door is the player's "no thanks" option when the other doors offer
  items they don't want.
- **Doors still all lead to the same next room** — the choice is *which item*,
  not *which path* (routing stays until RunManager, Phase 6 D).
- Random draw stays **uniform** over the owned pool.

## Functional Requirements

- **Run pool moves to GameState** (autoloads own run state): an
  `Array[MagicItemResource]` starting as `[fire_orb]`; `reset_run()` resets it.
  The Bag reads the run pool instead of its static `item_pool.tres` when one is
  active (the `.tres` remains the smoke test's injection mechanism and the
  full-catalog reference).
- **Offer generation:** on `room_cleared`, the room assigns each open door a
  distinct random item from the full catalog.
- **Offer display:** the item hovers over the open door — `appearance` texture
  when it exists, graybox swatch otherwise (same fallback as the HUD). Subtle
  bob (existing juice idiom) so it reads as pickable.
- **Pickup:** the door's `player_entered` flow adds the item to the run pool if
  not owned (no-op if owned), then transitions as today. A small SFX/flash on
  actual pickup; silence on the no-op (readability: something happened vs not).
- Persists across rooms via GameState; resets on New Game and after death →
  menu.
- Win screen unchanged (with 2 rooms today the run sees up to 2 pickups; the
  system blooms when Phase 6 D adds floors).

## Architecture

- Door gains an `offered_item: MagicItemResource` set by the room at clear time
  — the door only *displays and reports*; the room orchestrates; GameState owns
  the pool (UI/gameplay separation preserved).
- New EventBus signal `item_unlocked(item_data: MagicItemResource)` for
  SFX/HUD/future use (announce the fact; whoever cares connects).
- No changes to Bag draw logic beyond pool sourcing.

## Acceptance Criteria

- Fresh run: every draw is Fire Orb until a pickup happens.
- Cleared room: 3 doors, 3 distinct offers displayed; entering one adds exactly
  that item; the next room's draws include it.
- Picking an owned item changes nothing (pool size and weights identical).
- New Game resets the pool to Fire Orb only.
- Smoke: pool starts at 1; pickup adds; duplicate pickup is a no-op; offers
  distinct; countdowns unaffected. Green.

## Out of Scope

- Pool visibility in the HUD (cut in Spec 009; open question below).
- Weighted draws, item removal, curses/blessings.
- Door routing choices (Phase 6 D).

## Open Questions

1. **Pool visibility:** shipping without any "what's in my bag" UI — remembering
   your build is part of the game for now. Revisit after playtest?

## Resolved

- **No guarantee of an unowned offer** (Rafael, 2026-07-27): with a 20-stage MVP
  and a 6-item catalog, all-owned rooms are the norm in the late run — offers
  stay purely random (still distinct within a room). All-"no thanks" rooms are
  accepted and expected.
