# Spec 012 - Troy the Wooden Horse

**Status:** Implemented (2026-07-26)

## Goal

Add Troy, an item that behaves like a normal bomb **except for how it moves
once it leaves the hand** — instead of a 2-tile hop it charges in an L (a chess
knight's path), damaging anything it touches until it reaches a wall.

## Gameplay Description

Appearance: a wooden chess-knight. Drawn, held, and blinking down like any
other item (the countdown runs the whole time — no safe state). When **thrown**,
Troy charges fast in the throw direction; on hitting the scenario limit it turns
90° once (the L), then charges to the next wall and stops. It damages any
character it touches while moving (enemies and the player — pillar 4). It
destroys itself when its countdown ends, like every other bomb.

## Functional Requirements

- Extends MagicItemResource/MagicItem. Same countdown/blink/held behaviour as
  other items. `activation_time_seconds = 4`.
- New resource flag `charge_on_throw = true`. When set, `throw(direction)`
  starts an L-charge instead of the normal 2-tile fly:
  - move at `CHARGE_SPEED` in the throw direction;
  - on hitting a wall (scenario limit), turn 90° toward open space **once**;
  - on the second wall, stop (state = LANDED) and wait out the countdown.
- Contact damage: while charging, each character within contact range takes 1
  hit, once per character (a per-charge hit set). Troy is not in the "enemies"
  group, so it bypasses the player's i-frames — correct, it's the player's own
  item.
- Countdown end destroys Troy (its `effect` is null — no area blast; the danger
  is the contact charge). `_trigger` must guard a null effect.
- Appearance: AtlasTexture at sheet region (192, 96, 32, 32).

## Architecture

- All inside `MagicItem` (no separate hazard scene): a charge branch in
  `throw()`, an `_physics_process` charge stepper (raycast wall detection +
  perpendicular-toward-open turn), and a per-frame contact-damage pass.
- `MagicItemResource` gains `charge_on_throw: bool` (default false); every
  existing item is unaffected.

## Acceptance Criteria

- Thrown Troy charges in an L and stops at the second wall.
- It damages an enemy (and the player) it passes through, once each.
- Its countdown still destroys it on time, mid-charge or after it stops.
- No existing item changes behaviour (charge_on_throw defaults false).

## Out of Scope

- A separate spawnable Troy hazard (not needed — it stays a MagicItem).
- Multi-turn / repeating knight patterns beyond a single L.
