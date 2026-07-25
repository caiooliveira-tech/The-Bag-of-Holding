# Spec 005 - The Right Hand of Ursula

**Status:** Not Started

## Goal

Implement The Right Hand of Ursula as the second concrete MagicItem for the MVP, validating a non-damage effect_type (crowd control) in the framework (Spec 003).

## Gameplay Description

Appearance: a mummified right hand with a magic sigil on its open palm. Drawing it and letting its timer run out roots every character caught in its radius in place.

## Functional Requirements

- Extends MagicItemResource/MagicItem (Spec 003).
- `effect_type = freeze_area`
- `radius_tiles = 1` (all directions from the item's position; 1 tile = 32 px)
- `freeze_duration_seconds = 5`
- `activation_time_seconds = 4`
- Must be able to freeze the player as well as enemies.
- **Freeze is movement-lock only** (confirmed 2026-07-25): a frozen character cannot move, but can still attack and still be attacked. It is crowd control, not a full action-lock — this makes the item both a defensive tool and an offensive setup tool.

## Acceptance Criteria

- Triggers exactly 4 seconds after draw, regardless of held/thrown state.
- Freezes movement of all valid targets within a 1-tile radius for 5 seconds from trigger.
- Frozen targets can still attack and take damage during the freeze.

## Test Cases

- An enemy frozen mid-patrol stays in place for exactly 5 seconds, then resumes its prior behavior.
- The player standing in their own item's radius at trigger is frozen too.
- A frozen enemy in attack range still attacks the player; a frozen enemy still takes damage from a Fire Orb.

## Out of Scope

- Sigil/glow VFX
- Sound design
