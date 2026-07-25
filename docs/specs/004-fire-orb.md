# Spec 004 - Fire Orb

**Status:** Not Started

## Goal

Implement the Fire Orb as the first concrete MagicItem, validating the framework (Spec 003) end-to-end for the MVP.

## Gameplay Description

Appearance: a fire lamp/lantern. Drawing it and letting its timer run out triggers a burning explosion around it.

## Functional Requirements

- Extends MagicItemResource/MagicItem (Spec 003).
- `effect_type = area_damage`
- `damage_tier = medium`
- `radius_tiles = 1` (all directions from the item's position; 1 tile = 32 px)
- `activation_time_seconds = 3`
- Damage window lingers for 1 second after trigger.
- **The lingering window deals at most 1 hit total per target** (decided 2026-07-25) — a target caught in the area takes one hit, whether at trigger or by walking in during the linger; it never ticks repeatedly.
- Must be able to damage the player as well as enemies if either is in radius at trigger time.

## Acceptance Criteria

- Triggers exactly 3 seconds after draw, regardless of held/thrown state.
- Deals medium fire damage to all valid targets within a 1-tile radius.
- The damaging area persists for 1 second after the initial trigger, dealing at most 1 hit per target across the whole window.

## Test Cases

- An enemy standing in the radius at trigger time takes damage.
- The player standing on their own dropped/thrown Fire Orb at trigger time takes damage too.
- A target that stays inside the lingering area for the full second takes exactly 1 hit, not multiple.
- A target that walks into the area during the 1s linger (but wasn't there at trigger) still takes 1 hit.

## Out of Scope

- VFX polish (Art Direction)
- Sound design
