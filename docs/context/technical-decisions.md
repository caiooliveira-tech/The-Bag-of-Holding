# Technical Decisions

Document long-term technical constraints and conventions here.

## Engine & Runtime

- **Engine:** Godot 4.6.
- **Scripting language:** GDScript (no Mono/C# build present — do not introduce
  C# without an explicit decision here).
- **Rendering method:** Forward+.
- **3D physics engine:** Jolt Physics.
- **Windows rendering driver:** Direct3D 12.

These are already encoded in `project.godot`; they're recorded here so the
reasoning/constraint is visible without having to diff the engine config.

## Pending Decisions

Not yet decided — flag before assuming an answer in a spec:

- Target platforms / export presets.
- Controller/gamepad support.
- Localization strategy.
- Multiplayer/networking (assume single-player until decided otherwise).
