# Spec 002 - Bag System

**Status:** Not Started

## Goal

Implement the Bag of Holding system independently from the Player — owning the item pool, the random draw, and the held/thrown/landed state — so the Player Controller only sends input events and reacts to signals.

## Gameplay Description

On Attack input, the Bag draws one random item from the current pool and instantiates it in a "held" state above the player. A second Attack input throws it in the facing direction (default range: 2 tiles = 64 px), or it can be redirected further by the Apprentice Boot kick (5 tiles). The item's countdown begins the moment it is drawn, not when it is thrown — it runs identically whether held, in flight, or landed.

## Player Experience

The player should always be able to tell, at a glance, what they're holding and roughly how urgent it is — without reading a number (see art-direction.md's escalating-blink-rate rule).

## Functional Requirements

- Maintains the current run's item pool (MVP: Fire Orb, Right Hand of Ursula — see game-overview.md Scope).
- On draw: pick uniformly at random from the pool, instantiate the corresponding MagicItem (Spec 003), and start its countdown immediately.
- Held item visually follows the player until thrown.
- On throw: launch in the facing direction, default travel = 2 tile-units (1 tile = 32 px), then settle into "landed" state. The held→landed transition does not affect the countdown.
- On kick (Apprentice Boot, separate spec): redirect an already-thrown/landed item 5 tile-units further in the kicker's facing direction.
- When the countdown reaches zero: trigger the item's effect (Spec 003) regardless of held/thrown/landed state, then despawn/return the item.
- The Bag never applies damage directly — it only manages state and delegates effect resolution to the MagicItem instance.

## Non-Functional Requirements

- Item pool and draw logic must be testable independent of the Player scene — no direct references to Player nodes; communicate via signals only.

## Scene Structure

`systems/bag/bag.tscn` — a logic node (visual root optional) holding a spawn/attach point for the currently-held item.

## Nodes

- Bag root node
- Held-item attach point Marker

## Scripts

- `bag.gd` — draw/hold/throw state and pool management

## Signals

- `item_drawn(item_id)`
- `item_thrown(item_id, position, direction)`
- `item_landed(item_id, position)`
- `item_kicked(item_id, new_position)`
- `item_effect_triggered(item_id)`

## Resources

- `ItemPoolResource` — array of MagicItemResource references representing the currently unlocked/equipped set (MVP hardcodes Fire Orb + Right Hand of Ursula).

## Acceptance Criteria

- Random draw from the current pool on Attack input.
- Countdown starts on draw, independent of held/thrown state.
- Throw launches the item 2 tiles in the facing direction by default.
- Bag has zero hard dependencies on Player internals.

## Test Cases

- Drawing from a 2-item MVP pool never errors or returns null.
- An item whose countdown elapses while still held (never thrown) still triggers its effect on time, at the player's position.
- Throwing changes position but not the countdown.
- Kicking a landed item moves it 5 tiles without resetting its countdown.

## Out of Scope

- Effect resolution itself (Spec 003 + per-item specs)
- Blink-rate UI rendering (art-direction.md)
- Item unlock/discovery system (post-MVP)
