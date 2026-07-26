# Spec 009 - HUD: Special-Item Slots

**Status:** MVP scope implemented on `feature/hud-special-slots` (2026-07-26, PR #3);
post-MVP sections remain Draft · MVP scope narrowed 2026-07-26

**Supersedes:** the *bag-pool* region of Spec 008 (bottom-right). Hearts (left) are
unchanged; the held-item box keeps its Spec 008 behavior but is repositioned (see MVP
Scope → held-item box position).

> **MVP decision (2026-07-26, team, in person):** the two special slots are **not** in
> the MVP HUD. For the MVP the bottom bar is **hearts (left) + the held-item box** only
> — no right-side region. The Spec 008 bag pool is dropped and no special slots are added
> yet. The special-slot design in this spec is retained as the **post-MVP** target.

## Goal

- **MVP (this branch):** trim the bottom HUD bar to hearts (left) + the held-item box;
  retire the Spec 008 bag-pool region on the right. No special slots.
- **Post-MVP:** the right region gains two special-item slots (🔺/⭕ equip buttons from
  the design doc).

Both are presentation only — zero gameplay logic (game-architecture.md rule; UI never
runs gameplay).

## Context

The design doc gives Shoelace two special-equip buttons — Triangle (🔺) and Circle (⭕)
— for equippable specials (Apprentice Boot, amulets, etc.). Flavio's wireframe first
showed those two slots on the right; the team then decided (2026-07-26) they're out of
the MVP HUD. So the MVP HUD keeps only hearts + the held-item box, and the special-slot
work below moves to post-MVP.

## MVP Scope (this branch)

- Keep the single bottom bar; central play area stays clean (Brawl Stars / Bomberman
  rule). Hearts (bottom-left) and the held-item box behave exactly as Spec 008 (the
  box's *position* changes — see below).
- **Remove the bottom-right region:** drop the `PoolBox` bag-pool display from
  `hud.tscn` / `hud.gd`. The right side is empty for the MVP.
- **Held-item box position (provisional):** with the right-side region gone, move the
  held-item box toward the **right** of the bar rather than leaving it dead-center, so
  the two remaining elements — hearts far-left, item box on the right — fill the bar more
  harmonically. This is a layout call only, **subject to change as we iterate**.
- Net MVP HUD: **hearts (left) + held-item box (shifted right; see position note)**.
- Presentation only: reacts to EventBus + group lookups; never calls gameplay methods.
- **Art-ready texture hooks (graybox fallback):** every graybox element has a texture
  twin that replaces it automatically when a texture is assigned in the editor — zero
  code changes when art lands:
  - Hearts: one exported `heart_texture` on the HUD root applies to all 5; lost hearts
    dim via exported `heart_empty_tint`.
  - Bar background: drop the wooden-slab texture on the `BarBgTex` NinePatchRect in
    `hud.tscn` (9-patch margins tweakable in-editor).
  - Held-slot frame: drop the frame texture on `SlotFrameTex` (NinePatchRect).
  - Item pictures already flow from each item's `.tres` `appearance` (Spec 008).
- **Art status (2026-07-26):** wooden bar (`assets/ui/wooden_bg.png` on `BarBgTex`),
  held-slot frame (`assets/ui/item_container.png` on `SlotFrameTex`, native 92×99, pokes
  above the plank per mockup) and item icons (200×200 frames from
  `systems/magic_items/spritesheet.png`, coords per `spritesheet.json`, wired as
  `AtlasTexture` sub-resources into each item's `.tres` `appearance`) are **integrated**.
  Two spare icons (devil_horns, chess_knight) sit ready for the post-MVP Left Hand /
  Troy items. **Still missing from Design: a heart icon (~28 px transparent PNG)** —
  hearts render as graybox squares until it lands (one Inspector assign to
  `heart_texture`).
- Known nit: the item-name label clips long names in the 92 px box (mockup shows no
  label) — pending team call on hiding it.

### MVP Acceptance Criteria

- Bottom bar shows hearts (left) + the held-item box (shifted right per the position
  note); no bag pool, no special slots.
- Spec 008 behavior intact: hearts dim on damage and persist across rooms; the held-item
  box fills on draw and clears on throw/detonation.
- HUD contains no gameplay logic (EventBus + group lookup only).
- Game still loads and a room is fully clearable (iteration stays playable).
- Art-swap check: assigning a texture (heart export / BarBgTex / SlotFrameTex) in the
  editor replaces the corresponding graybox with zero code edits.

---

## Post-MVP: Special-Item Slots

> Deferred by the 2026-07-26 MVP decision. Kept here so the design is ready when the
> special-item gameplay system is built. Not part of this branch's shippable MVP.

### Functional Requirements

- **Special slots — bottom-right:** exactly two slots.
  - Left slot bound to **Triangle (🔺)**, right slot to **Circle (⭕)** — order per
    wireframe. Each slot renders its button glyph.
  - **Empty state:** slot drawn empty/glowing with only the button glyph, from exported
    textures with a graybox fallback (see Extensibility) — no final art required.
  - **Equipped state:** slot shows the equipped special's icon (appearance texture, else
    graybox color) + button glyph.
  - **Availability feedback:** a slot on cooldown / unusable renders dimmed; ready =
    full. No numbers (design rule: urgency via visuals, not counters).

### Extensibility & Art Swap (team-facing)

A core requirement when this is built: the team must be able to restyle the HUD and drop
in final sprites **from the Godot editor, without touching code**.

- **All slot visuals come from exported `Texture2D` fields** (slot frame, empty-slot
  look, button glyph), editable in the Inspector, with the graybox fallback above.
- **One reusable slot scene** (see Scene Structure) so restyling one slot restyles both,
  and adding/removing a slot is an editor operation, not a code change.
- **Glyphs are data, not hardcoded** — the 🔺/⭕ prompt is an exported texture per slot,
  so swapping to keyboard prompts or new button art later is an Inspector change.
- **Colors/theme exported** (or a shared Godot `Theme` resource) rather than `const`s in
  code, so palette changes (Silas/Flavio) don't require editing scripts.

### Data Contract (EventBus)

The HUD consumes — it does not own — special state. The special-item system (future
spec) will emit these; declare them on EventBus when that system is built:

- `special_equipped(slot: int, item_data: SpecialItemResource)` — slot 0 = 🔺, 1 = ⭕.
- `special_used(slot: int)` — for a use/flash cue.
- `special_cooldown_changed(slot: int, remaining: float, total: float)` — drives the
  dim/ready feedback.

### Scene Structure

- **Reusable component `ui/special_slot.tscn` (+ `special_slot.gd`).** One slot = one
  instance; the two slots (🔺, ⭕) are two instances of the same scene, so adding a third
  later is just dropping another instance — no new code.
- Each slot is built from nodes in the scene (editor-editable), **not** `.new()` in code:
  a `Frame` (background), a `Glyph` (button prompt), and an `Icon` holder for the
  equipped special — each taking an exported `Texture2D`.
- `special_slot.gd` exposes a small typed API (e.g. `set_equipped(item_data)`,
  `set_ready(is_ready)`) so `hud.gd` drives slots without reaching into their internals.

### Post-MVP Acceptance Criteria

- Right region shows two slots with 🔺 and ⭕ glyphs; equipped specials show their icon;
  a slot on cooldown renders dimmed.
- Replacing a slot's exported frame/glyph texture in the Inspector changes its appearance
  with zero code edits (art-swap check).

## Dependencies & Open Questions

- **Bag pool:** resolved — dropped for the MVP HUD (2026-07-26 decision).
- **Input map (post-MVP):** the map currently ships a single `special` action; two slots
  imply two actions (e.g. `special_triangle` / `special_circle`). That change belongs to
  the special-item gameplay system spec and likely warrants an ADR when implemented.
- **Glyphs (post-MVP):** wireframe shows PlayStation face-button glyphs; the input map
  also has keyboard bindings. Assume PS glyphs first; adaptive prompts are later.
