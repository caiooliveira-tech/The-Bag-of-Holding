# Spec 011 - The Left Hand of Ursula

**Status:** Implemented (2026-07-26)

## Goal

Add the Left Hand of Ursula, a third area item, validating a *knockback*
effect_type in the framework (Spec 003) — a new subclass + `.tres`, no
base-class changes.

## Gameplay Description

Appearance: a mummified left hand (pink sigil). Drawing it and letting its
timer run out shoves every character in its radius **away from the blast
center**, hard. It can shove the player too (pillar 4).

## Functional Requirements

- Extends MagicItemResource/MagicItem; `effect_type = knockback_area`.
- `radius_tiles = 1`, `activation_time_seconds = 3`.
- On trigger: each target in radius gets a knockback impulse pointing from the
  blast center outward (targets at the exact center get a default direction).
- `knockback_speed` tunable on the effect resource; the impulse decays like the
  player's existing hit-knockback.
- Affects enemies and the player. Enemies gain knockback support (they had none).
- Appearance: AtlasTexture at sheet region (192, 64, 32, 32).

## Architecture

- New `KnockbackAreaEffect extends MagicItemEffect` (`effect_kind = knockback_area`,
  `preview_radius_tiles` = radius). Both Player and Enemy expose
  `apply_knockback(impulse: Vector2)`; the enemy decays `_knockback` in its
  movement just like the player.
- Camera: a `knockback_area` trigger gets a medium shake (forceful, not an
  explosion).

## Acceptance Criteria

- An enemy in radius is flung outward and drifts to a stop.
- The player standing in their own Left Hand radius is flung too.
- Adding the item required only a new effect subclass + a `.tres` + a pool entry.

## Out of Scope

- Knockback into walls dealing extra damage (design idea, not now).
- VFX beyond a ring + shove particles.
