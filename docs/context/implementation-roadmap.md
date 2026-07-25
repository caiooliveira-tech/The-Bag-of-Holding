# Implementation Roadmap

> Goal: always maintain a playable build.
>
> During the GMTK Game Jam, progress is measured by playable vertical slices,
> not by the number of completed systems.

---

# Development Strategy

This project follows a **Vertical Slice** approach.

Each phase must end with a game that someone can immediately play.

Never spend multiple phases building infrastructure without validating gameplay.

Priority order:

Gameplay > Polish > Architecture > Extra Features

---

# Phase 0 — Foundation

Goal:

Create the project's technical foundation.

Tasks

- Import all context documentation
- Validate folder structure
- Configure autoloads
- Configure project settings
- Commit initial repository structure

Deliverable

✓ Project opens correctly
✓ Documentation synchronized
✓ Repository ready for implementation

---

# Phase 1 — First Playable Build

Goal

Validate movement and combat feel.

Tasks

- Player Controller (Spec 001)
- Dash
- Camera
- One graybox room
- One enemy
- Enemy chase
- Enemy attack
- Discrete hit damage
- Blink damage feedback

Deliverable

✓ Player can enter a room
✓ Enemy attacks player
✓ Enemy dies

Fun is more important than visuals.

---

# Phase 2 — Core Game Mechanic

Goal

Validate the Bag of Holding mechanic.

Tasks

- Bag System (Spec 002)
- Magic Item Framework (Spec 003)
- Fire Orb (Spec 004)

Deliverable

✓ Draw item
✓ Hold item
✓ Throw item
✓ Countdown
✓ Explosion
✓ Damage

This is the most important milestone of the project.

---

# Phase 3 — Gameplay Validation

Goal

Prove the game's second gameplay pillar.

Tasks

- Right Hand of Ursula (Spec 005)
- Freeze effect
- Countdown feedback
- Improved visual feedback

Deliverable

✓ Two different items
✓ Two different gameplay strategies

---

# Phase 4 — Content Integration

Goal

Transform prototype into a game.

Tasks

- Room transitions
- Door system
- UI
- HUD
- Art integration
- Audio integration

Deliverable

✓ Complete gameplay loop

Player

↓

Room

↓

Combat

↓

Reward

↓

Next Room

---

# Phase 4.5 — HUD: trim to hearts + held item (special slots → post-MVP)

> Added post-Phase-4 (2026-07-25); MVP scope narrowed 2026-07-26 (team). An increment on
> the shipped HUD, not part of the original 7-phase plan. Built on its own feature branch
> with a draft PR kept open for team review; every iteration ends on a playable build.

Goal

Trim the bottom HUD bar to hearts (left) + the held-item box for the MVP — drop the
bag-pool region and shift the item box right to balance the bar (provisional layout).
The two special-item slots (🔺/⭕) are deferred to post-MVP.

Tasks

- Spec 009 (HUD: Special-Item Slots) — MVP scope + retained post-MVP design
- Remove the bottom-right bag-pool region from hud.tscn / hud.gd
- Keep hearts + held-item box (Spec 008 behavior intact)

Deliverable

✓ Bottom bar: hearts (left), held-item box (shifted right); no right-side region
✓ Spec 008 behavior intact (hearts, held item)
✓ Build stays playable

Post-MVP (not this phase): the two special-item slots + the special-item gameplay system
(equipping, cooldowns, effects).

---

# Phase 5 — Ship

Goal

Prepare final submission.

Tasks

- Bug fixing
- Balance
- Performance review
- Export
- Itch.io upload
- Submission

Deliverable

✓ Final build

---

# Stretch Goals

Only start these after Phase 5.

- More rooms
- Additional enemies
- Additional items
- Extra VFX
- Camera shake improvements
- Music improvements

---

# Cut List

The following features are intentionally outside the MVP.

- Atomic Orb
- Magnetic Horseshoe
- Left Hand of Ursula
- Troy the Toy Horse
- Equipment system
- Item unlock progression
- Multiple floors

---

# Definition of Done

A phase is complete only when:

- Gameplay works
- No critical bugs
- Playtested
- Documentation updated
- Main branch remains playable