# Spec 003 - Magic Item Framework

**Status:** Not Started

## Goal

Define the base architecture all magic items share, so each new item (Fire Orb, Right Hand of Ursula, and any future catalog additions) is a data-plus-behavior extension rather than one-off code per item.

## Gameplay Description

Every magic item has an appearance, an activation time (seconds from draw to effect), and an effect (area damage, crowd control, movement, etc.) that fires once, when its countdown reaches zero — regardless of whether it's currently held, thrown, or landed.

## Player Experience

Indirect (this is an internal framework spec), but its correctness underpins the "timing over reflexes" pillar: every item must behave identically and predictably whether the player is still holding it or has already thrown it.

## Functional Requirements

- Base `MagicItemResource` (data): id, display_name, appearance (sprite ref), activation_time_seconds, effect_type (enum), effect_params (shape varies per effect_type — e.g. damage_tier, radius_tiles, duration_seconds).
- Base `MagicItem` (behavior): tracks elapsed time since draw regardless of held/thrown/landed sub-state, exposes time_remaining, and emits effect_triggered when the countdown hits zero, then invokes its effect resolver.
- Effect resolution must be able to affect the player, not just enemies — self-damage/self-effect is a core mechanic, not an edge case.
- MVP needs exactly two effect_types: `area_damage` (Fire Orb) and `freeze_area` (Right Hand of Ursula). Design the enum/resolver so future types (movement, pull/magnetize, knockback) don't require touching the base class.
- Damage goes through the discrete hit-count system — no percentage/HP-bar math anywhere in this framework.
- Radii are expressed in tile-units; 1 tile = 32 px.

## Non-Functional Requirements

- Per godot-standards.md, use Resources for the data half so item balance (damage tier, radius, timing) is tunable without touching GDScript.

## Scene Structure

`systems/magic_items/magic_item_base.tscn` (or pure script if no standalone visuals are needed) + one scene/resource pair per concrete item under `systems/magic_items/`.

## Nodes

- Root node representing the item in the world: sprite + an Area sized to radius_tiles for effect resolution.

## Scripts

- `magic_item.gd` — base countdown/state logic
- Per-effect_type resolver (composition over one giant match, per godot-standards.md)

## Signals

- `countdown_started`
- `effect_triggered(item_id, position)`
- `effect_resolved(item_id, affected_targets)`

## Resources

- `MagicItemResource` (base) + one `.tres` per catalog item — MVP needs `fire_orb.tres` and `right_hand_of_ursula.tres`.

## Acceptance Criteria

- A new item can be added by authoring a `.tres` (plus a new effect resolver if it needs a new effect_type) without modifying Bag or Player scripts.
- Countdown timing is fully state-independent (held/thrown/landed).
- Effects can affect the player as well as enemies.

## Test Cases

- Fire Orb (activation_time_seconds = 3) triggers area_damage exactly at 3s from draw.
- Right Hand of Ursula (activation_time_seconds = 4) applies a 5s movement-lock in a 1-tile radius, including to the player if in range.
- Two items drawn/thrown in quick succession resolve independently — no shared timer state between instances.

## Out of Scope

- Enemy AI reaction to items (Enemy Framework spec, Phase 2)
- UI/blink-rate rendering
- Item pool/unlock progression
