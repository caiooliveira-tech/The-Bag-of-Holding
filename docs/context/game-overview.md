# Game Overview

## Vision

A top-down roguelike about turning a bottomless magic bag into your entire arsenal — and your biggest liability. Every item you draw is a countdown you have to out-think, both against enemies and against yourself.

## Elevator Pitch

Shoelace, a clumsy wizarding apprentice, must climb Violet the witch's tower to rescue his mentor Euclidus. His only weapon is the Bag of Holding — a sack that turns anything placed inside it into a magic bomb with its own timer and effect. Draw an item, decide when to throw it, and don't get caught in your own blast radius.

## Core Gameplay Loop

1. Press Attack → draw one random item from the Bag. The item's countdown starts immediately on draw, whether it's held or thrown.
2. Hold the item (it stays raised, following the player) or press Attack again to throw it (default range: 2 tiles) in the facing direction.
3. The countdown keeps running identically whether the item is held, in flight, or landed — there is no "safe" state.
4. When the countdown hits zero, the item's effect triggers (area damage, freeze, knockback, etc.) and can hit the player as well as enemies. Dash grants invulnerability to enemy attacks only — never to the player's own item effects.
5. Clear all enemies in the room → doors open → pick a staircase → pick one already-discovered item to add to the Bag's pool for the next floor.
6. Repeat, climbing the tower toward Violet.

## Player Fantasy

An underpowered apprentice who wins not through reflexes but through reading countdowns and controlling space — every draw is a small risk-management puzzle against both the enemies on screen and the ticking object in your own hand.

## Scope

### In Scope (MVP — GMTK Jam 2026 build)

- 8-directional movement + dash/dodge (i-frames vs. enemy damage only)
- Single Attack input: draw → hold → throw
- Two magic items: Fire Orb (area damage) and The Right Hand of Ursula (freeze)
- Apprentice Boot special: kick (1 dmg to enemies, or redirects a thrown item 5 tiles)
- Simple enemy AI: fixed patrol or direct chase within a proximity radius
- Discrete hit-count damage (no HP bars, no percentages)
- Gray-box prototyping before final art integration
- At least one clearable room/floor loop

### Out of Scope (post-MVP / stretch, if time allows)

- Remaining item catalog: Left Hand of Ursula, Troy the Toy Horse, Magnetic Horseshoe, Atomic Orb
- Remaining specials: Amulet of Harris, Amulet of Atuin, The Broken Hourglass, Visible Time Glasses
- Item discovery/unlock system across floors
- Multi-floor tower progression beyond the MVP room count
- Boss encounters
- Cross-run build/meta-progression

## Success Criteria

- A playable build submitted to itch.io before the GMTK Jam 2026 deadline (July 26).
- A new player understands the draw → hold/throw → countdown → effect loop, including the self-damage risk, within ~2 minutes of play.
- At least one full room clear is demonstrable using both MVP items.
