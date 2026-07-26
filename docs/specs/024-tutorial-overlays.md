# Spec 024 - Tutorial Overlays (Level 1)

**Status:** Draft (2026-07-28)

**Pairs with:** Spec 016 (level 1 is the tutorial floor) and Spec 022 (reuses
the parchment/ink front-end look).

## Goal

Teach the loop inside the game instead of in a manual: a parchment overlay
that pauses play, says one thing, and closes on **SPACE**. Two beats on level 1
— first *how to fight*, then *what clearing a floor gets you*.

## The Beats (storyboard, Rafael 2026-07-28)

| # | Trigger | Copy |
| --- | --- | --- |
| 1 | Level 1 starts | *Press **SPACE** to use the items in your bag to kill all enemies in every floor.* |
| 2 | Level 1 cleared | *Clearing the floors **unlocks** the doors that grant you new items for your bag. Use them wisely, as they are **drawn randomly** from it.* |

> **Copy note:** beat 2 is shown here with three small grammar fixes vs. the
> mockup ("unlock" → "unlocks", "to your bag" → "for your bag", "randomly draw
> from it" → "drawn randomly from it"). Flagged for the team to accept or veto —
> the mockup wording is otherwise preserved.

Beat 1 lands while the tutorial enemy is **penned behind walls** (Spec 016,
`PEN`): the player can try the controls, throw an item, and even blow themselves
up — discovering the heart bar — without dying to an enemy that can't reach
them. Beat 2 fires when that enemy dies, right before the doors open with their
item offers, so the reward is explained exactly when it appears.

## Functional Requirements

- Overlay = parchment panel (`bg.png`) centered-right over the live room, ink
  text, and a small `[SPACE] CLOSE` button caption, matching the mockup.
- **Pauses gameplay** while open (`get_tree().paused`), with the overlay itself
  on `PROCESS_MODE_ALWAYS`. Countdowns, enemies and input all freeze — a beat
  can't get the player killed while they read.
- **SPACE closes.** ESC does not (it's the pause menu); any other key is
  ignored, so a player mashing attack doesn't skip the lesson unread.
- Each beat shows **once per run** (a beat already seen is not re-shown when
  the level restarts after death).
- Fades in/out (~0.2 s) so it doesn't snap over the room.
- Data-driven: adding a beat to any level is a `.tres` edit.

## Architecture

- **`TutorialBeatResource`** (`systems/tutorial/`): `text`, `trigger` enum
  (`LEVEL_START`, `LEVEL_CLEARED`), shipped as two `.tres` referenced from
  level 1's `LevelResource.tutorial_beats` (Spec 016).
- **`TutorialOverlay`** autoload (CanvasLayer) — mirrors the existing
  `DeathScreen` / `Pause` / `LevelTitle` pattern: it listens to
  `EventBus.level_entered` and `EventBus.room_cleared`, matches beats from the
  current level's data, and shows them. Rooms and enemies stay unaware of it.
- Built from `MenuUI` tokens, so it inherits the front-end's look for free.

## Acceptance Criteria

- Starting level 1 shows beat 1; the game is frozen until SPACE.
- Killing the penned enemy shows beat 2 before/while the doors open; SPACE
  resumes and the item offers are visible.
- Levels 2–12 show no overlays.
- Dying on level 1 and retrying does not replay a beat already seen.
- Pause (ESC) still works normally after an overlay closes; smoke test green.

## Out of Scope

- A full hint system for later floors (item-specific tips, "kick the bomb"),
  contextual prompts, or a replayable "How to play" menu entry — the system
  supports more beats, this spec ships two.
- Controller glyphs (the copy says SPACE; gamepad users see the same text).

## Open Questions

1. **Movement controls** are never stated. Add a line to beat 1 (e.g. *"Move
   with WASD, dash with SHIFT"*), or trust players to try? *Proposal: add it —
   it costs one line and removes the only other thing they must guess.*
2. Accept the three grammar fixes in beat 2?
3. Should beat 1 wait for the first movement instead of firing instantly, so
   the room reads before the parchment covers part of it?
