# Art Direction

## Visual Style

Top-down, gray-box first (simple geometric primitives) to validate gameplay before final art lands. Once mechanics are validated, target a readable, stylized cartoon look in the spirit of Brawl Stars / Bomberman — clear silhouettes over fine detail, since combat readability matters more than fidelity at our scope and timeline.

## Color Palette

Owned by the Design/Visual front (Silas Chosen, Flavio Lee) — TBD. Suggested constraint: keep magic-item glow colors visually distinct from the environment palette so an active countdown reads instantly against any room.

## Animation Style

Prioritize legibility over frame count:

- Damage feedback uses blink/flash keyframes, not new sprites.
- Bomb countdowns use an escalating blink rate as detonation approaches, rather than a numeric timer.

## Audio Direction

TBD by the Design/Visual front. Per the team's AI-ethics decision (see docs/decisions/ADR-001-no-generative-ai-assets.md), all audio must be either created manually or sourced from free, non-AI-generated libraries.

## UI Principles

- The central screen area is reserved exclusively for gameplay (Brawl Stars / Bomberman-style layout).
- HUD elements (player health, currently-held item indicator) are pinned to screen edges, out of the play area.
- No numeric on-screen countdowns. Urgency is communicated by increasing blink/flash rate as an item's detonation approaches.
- No enemy HP bars. Damage state is communicated via a red flash on hit, plus a progressively darker/damaged tint as an enemy nears defeat.
