# Spec 009 - HUD: Special-Item Slots

**Status:** Draft (2026-07-25)

**Supersedes:** the *bag-pool* region of Spec 008 (bottom-right). Hearts (left) and
held-item (center) from Spec 008 are unchanged.

## Goal

Revise the bottom HUD bar so the right region shows the player's two **special-item
slots** (the 🔺/⭕ equip buttons from the design doc) instead of the Bag pool.
Still presentation only — zero gameplay logic (game-architecture.md rule; UI never
runs gameplay). Matches Flavio's updated wireframe (attached, 2026-07-25).

## Context

The design doc gives Shoelace two special-equip buttons — **Triangle (🔺)** and
**Circle (⭕)** — for equippable specials (Apprentice Boot, amulets, etc.). The
shipped HUD (Spec 008) instead rendered the Bag pool on the right; the new wireframe
retires that and shows two labelled special slots. This spec covers only the HUD's
*display* of those slots. The special-item gameplay system (equipping, cooldowns,
effects) is a separate, later spec — see Dependencies.

## Functional Requirements

- Keep the single bottom bar; central play area stays clean (Brawl Stars / Bomberman
  rule). Hearts bottom-left and held-item bottom-center are untouched (Spec 008).
- **Special slots — bottom-right:** exactly two slots.
  - Left slot bound to **Triangle (🔺)**, right slot bound to **Circle (⭕)** — order
    per wireframe. Each slot renders its button glyph.
  - **Empty state (this iteration's deliverable):** both slots drawn empty/glowing
    with only the button glyph, exactly as in the wireframe. Rendered from exported
    textures with a graybox fallback (see Extensibility), so it needs no gameplay
    system and no final art to exist yet.
  - **Equipped state (contract, rendered once the special-item system lands):** slot
    shows the equipped special's icon (appearance texture when present; graybox color
    until art lands — reuse the Spec 008 `_make_icon` pattern) + button glyph.
  - **Availability feedback:** a slot on cooldown / unusable renders dimmed; ready =
    full. No numbers (design rule: urgency via visuals, not counters).
- Presentation only: reacts to EventBus and group lookups; never calls gameplay
  methods, never mutates gameplay state.
- The checkered play area + decorative border belong to the room scene / art (Silas),
  not the HUD.

## Extensibility & Art Swap (team-facing)

A core requirement, not a nice-to-have: the team must be able to restyle the HUD and
drop in final sprites **from the Godot editor, without touching code**. Final HUD art
isn't ready yet, so this iteration grayboxes — but structured so the swap is trivial.

- **All slot visuals come from exported `Texture2D` fields** (slot frame, empty-slot
  look, button glyph), editable in the Inspector. Reuse the graybox-vs-texture fallback
  the item HUD already uses (`appearance` else `graybox_color`, hud.gd `_make_icon`):
  if a texture field is empty, draw the graybox placeholder instead.
- **One reusable slot scene** (see Scene Structure) so restyling one slot restyles both,
  and adding/removing a slot is an editor operation, not a code change.
- **Glyphs are data, not hardcoded** — the 🔺/⭕ prompt is an exported texture per slot,
  so swapping to keyboard prompts or new button art later is an Inspector change.
- **Colors/theme exported** (or a shared Godot `Theme` resource) rather than `const`s in
  code, so palette changes (Silas/Flavio) don't require editing scripts.
- Layout uses containers so any added element reflows instead of needing manual
  repositioning.

## Data Contract (EventBus)

The HUD consumes — it does not own — special state. The special-item system (future
spec) will emit these; declare them on EventBus when that system is built:

- `special_equipped(slot: int, item_data: SpecialItemResource)` — slot 0 = 🔺, 1 = ⭕.
- `special_used(slot: int)` — for a use/flash cue.
- `special_cooldown_changed(slot: int, remaining: float, total: float)` — drives the
  dim/ready feedback.

Until those exist, the HUD renders the empty state and simply has no equipped data to
show — so this spec ships and plays on its own.

## Scene Structure

- Extend `ui/hud.tscn` / `ui/hud.gd`: replace the `PoolBox` (HBoxContainer) on the
  right with a `SpecialSlots` HBoxContainer.
- **New reusable component `ui/special_slot.tscn` (+ `special_slot.gd`).** One slot =
  one instance; the two slots (🔺, ⭕) are two instances of the same scene, so adding a
  third later is just dropping another instance — no new code.
- Each slot is built from nodes in the scene (editor-editable), **not** `.new()` in
  code: a `Frame` (slot background), a `Glyph` (button prompt), and an `Icon` holder for
  the equipped special — each taking an exported `Texture2D` (per Extensibility).
- `special_slot.gd` exposes a small typed API (e.g. `set_equipped(item_data)`,
  `set_ready(is_ready)`) so `hud.gd` drives slots without reaching into their internals.

## Acceptance Criteria

- Bottom bar shows: hearts (left), held-item (center), two special slots with 🔺 and ⭕
  glyphs in empty state (right) — matching the wireframe.
- Existing Spec 008 behavior is intact: hearts dim on damage and persist across rooms;
  the held-item slot fills on draw and clears on throw/detonation.
- HUD contains no gameplay logic (EventBus + group lookup only).
- Game still loads and a room is fully clearable with the revised HUD (iteration stays
  playable).
- **Art-swap check:** replacing a slot's exported frame/glyph texture in the Inspector
  changes its appearance with zero code edits.

## Out of Scope

- The special-item **gameplay** system: equipping, binding, cooldowns, effects
  (Apprentice Boot kick already lives in the player controller from Spec 001). Separate
  future spec.
- Countdown numbers (forbidden), enemy HP bars (forbidden), final art/fonts.

## Dependencies & Open Questions

- **Input map:** the map currently ships a single `special` action; two slots implies
  two actions (e.g. `special_triangle` / `special_circle`). This change belongs to the
  special-item system spec and likely warrants an ADR when implemented — out of scope
  here, flagged so it isn't missed.
- **Bag pool:** the wireframe drops the bottom-right pool display. Confirm it's cut for
  MVP vs. relocated — this spec assumes cut.
- **Glyphs:** wireframe shows PlayStation face-button glyphs; the input map also has
  keyboard bindings. Assume PS glyphs for MVP; adaptive prompts are post-MVP.
