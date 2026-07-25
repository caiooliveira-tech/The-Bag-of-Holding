# Technical Decisions

Document long-term technical constraints and conventions here.

## Decided 2026-07-25

- **Aiming/facing:** movement-direction-based (Zelda/gamepad-style). Facing = last non-zero movement direction; no mouse aiming. Determines throw and kick direction.
- **Tile size:** 1 tile = 32 px. All tile-unit values (throw = 2 tiles, item radius = 1 tile, kick = 5 tiles, enemy detection ≈ 5 tiles) convert at this rate.
- **Player health:** Shoelace has 5 hits (max_health = 5). Enemy attacks deal 1 hit each.
- **Fire Orb linger:** the 1-second post-trigger damage area deals at most 1 hit total per target — no repeated ticks.
- **Freeze (Right Hand of Ursula):** movement-lock only. Frozen characters can still attack and be attacked.
- **Docs format:** all documentation lives as Markdown (.md) in the repo — no .docx. Word drafts were converted to .md on 2026-07-25.
