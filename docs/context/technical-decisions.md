# Technical Decisions

Document long-term technical constraints and conventions here.

## Engine & Runtime

- **Engine:** Godot 4.7 (per `project.godot` feature tag; running 4.7.1 stable).
- **Scripting language:** GDScript (no Mono/C# build present — do not introduce
  C# without an explicit decision here).
- **Rendering method:** Forward+.
- **3D physics engine:** Jolt Physics.
- **Windows rendering driver:** Direct3D 12.

These are already encoded in `project.godot`; they're recorded here so the
reasoning/constraint is visible without having to diff the engine config.

## Decided 2026-07-25

- **Aiming/facing:** movement-direction-based (Zelda/gamepad-style). Facing = last non-zero movement direction; no mouse aiming. Determines throw and kick direction.
- **Tile size:** 1 tile = 32 px. All tile-unit values (throw = 2 tiles, item radius = 1 tile, kick = 5 tiles, enemy detection ≈ 5 tiles) convert at this rate.
- **Player health:** Shoelace has 5 hits (max_health = 5). Enemy attacks deal 1 hit each.
- **Fire Orb linger:** the 1-second post-trigger damage area deals at most 1 hit total per target — no repeated ticks.
- **Freeze (Right Hand of Ursula):** locks movement. Enemies frozen still attack; **the player, frozen, cannot use the bag or the boot** (no drawing/throwing/kicking) — decided 2026-07-26, tightening the earlier "can still act" rule for the player only. Frozen characters can still be attacked.
- **Docs format:** all documentation lives as Markdown (.md) in the repo — no .docx. Word drafts were converted to .md on 2026-07-25.
- **Controller/gamepad support:** yes — the input map ships keyboard + gamepad bindings for every action (left stick, Cross/dash, Square/attack, Circle/special).

## Pending Decisions

Not yet decided — flag before assuming an answer in a spec:

- Target platforms / export presets (Phase 5, currently on hold).
- Localization strategy.
- Multiplayer/networking (assume single-player until decided otherwise).
