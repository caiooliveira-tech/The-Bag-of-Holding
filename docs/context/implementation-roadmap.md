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
- Art-ready texture hooks (hearts / bar background / slot frame) with graybox fallback,
  so Design's PNGs drop in via the editor with zero code changes

Deliverable

✓ Bottom bar: hearts (left), held-item box (shifted right); no right-side region
✓ Spec 008 behavior intact (hearts, held item)
✓ Build stays playable

Post-MVP (not this phase): the two special-item slots + the special-item gameplay system
(equipping, cooldowns, effects).

---

# Phase 4.6 — Game Feel (Juice)

> Added 2026-07-26 (team) after art integration. Spec 010. Polish pass over the
> functional combat loop: impact, motion, readability. No balance changes (except
> the flagged post-hit i-frames). Built on its own branch; each sub-phase (G1–G5)
> ends on a playable build with a green smoke test. Sub-phases are independent and
> individually cuttable.

Goal

Make combat *feel* good — camera shake, hitstop, tweened reactions, particles —
reinforcing readability, friendly-fire clarity, and fast combat, without touching
gameplay values.

Tasks (see Spec 010 for detail; ordered by impact-per-effort)

- **G1 Impact Core:** trauma-based camera shake, enemy death pop (flash/scale/
  particles/hitstop), player damage pack (hitstop + knockback + red vignette).
- **G2 Item Motion:** landing marker, visual arc + bounce (world position/timing
  unchanged), distinct freeze feel (zoom punch + frost, not shake).
- **G3 Survivability:** post-hit i-frames (enemy damage only) — **contains a
  difficulty decision, needs a team call**; unify with dash i-frames.
- **G4 Action Personality:** draw overshoot, explosion ring, urgency pulse,
  dash ghost trail.
- **G5 Atmosphere (stretch):** idle bob, door dust, room-clear flourish, rumble.

Deliverable

✓ Hits, kills, throws, and explosions read and feel physical
✓ Freeze feels cold, not violent; self-damage never blocked by i-frames
✓ Smoke test green after every sub-phase; no balance drift (except G3, decided)

---

# Phase 4.7 — Front-End & Narrative

> Spec 022 (title screen, brick/parchment menu art pass, level-title sign) —
> **shipped**. Spec 023 (cutscenes) added 2026-07-28 after Design delivered the
> 12-frame intro storyboard. Own branch, docs-only spec first, as always.

Goal

Wrap the game in its story and its look: a title screen, art-passed menus, and
an intro cutscene that explains the letter, the Bag, and the tower.

Tasks

- Spec 022 — title screen, menu redesign, level-title sign ✔
- Spec 023 — data-driven cutscene player (`CutsceneResource` + frame resources)
  and the intro: raven → letter → Bag → "I'll take the bag to the tower"
- Import the delivered raven / letter / bag art into `assets/cutscenes/`

Deliverable

✓ New Game → difficulty → intro cutscene → room_01, skippable with ESC
✓ Adding another cutscene (e.g. the ending) is pure data, no new code
✓ Smoke test green

---

# Phase 6 — Roguelike Progression (challenge & content)

> Added 2026-07-26 (team). Turns two dumb rooms into a designed 20-room run with
> a tutorial, escalating difficulty, smarter enemies, ranged combat, maze walls,
> and per-run item unlocks. Team decisions: **hybrid authoring** (walls painted
> per-room in a scene; enemies/palette/order as data in a RunManager) and
> **item choice at the door** (each open door offers an item added to the pool).
> Built in sub-phases (A–E), each ending on a playable build + green smoke test.

Goal

A continuous, flow-tuned 20-room MVP: teach one mechanic/enemy at a time, ramp
up, and let the player build an arsenal across the run.

Level structure (3 acts by palette)

- **Tutorial (rooms 1–4, blue):** one lesson each — move→draw→throw→countdown
  (1 weak chaser), friendly fire, wall-as-cover, introduce the chaser.
- **Escalation (5–13, pink):** introduce the ranged shooter isolated, then
  chaser+ranged combos, mazes, bigger groups.
- **Mastery (14–20, green):** dense mixes, tight mazes, full arsenal; room 20 =
  arena/finale.

Sub-phases

- **A — Interior walls + collision:** wall tiles (sheet y=160, 3 colour rows —
  closed / left-cap / right-cap / corner / center) added to a TileSet with
  physics; a paintable `Walls` TileMapLayer per room. Foundation for maze design.
- **B — Projectile + ranged enemy (Spec 014):** enemy projectile (sheet 160,0)
  that flies, damages the player, despawns on walls/range; enemy type 2 kites to
  a preferred distance and shoots on cooldown.
- **C — Smarter chaser (Spec 015):** replace the magnet — separation (no
  clumping), strafe/flank, wall-aware steering, telegraphed lunge. Parameterized.
- **D — Run structure (Spec 016):** `RunManager` sequences the 20 rooms (data:
  palette + enemy spawns + wall-layout ref per room), advances on clear+door,
  cycles the 3 palettes, encodes the difficulty curve.
- **E — Item unlock at doors (Spec 017):** on clear, each open door shows an
  item; walking through picks it into the run's pool. Pool starts at Fire Orb
  and grows; persists across rooms via GameState. Team rules (2026-07-27):
  offers come from the full catalog, distinct per room; duplicates of owned
  items are allowed and act as the "no thanks" door (picking them does
  nothing). Prerequisite: complete the catalog first — **Spec 020 (Magnetic
  Horseshoe)** and **Spec 021 (Atomic Orb)** — so doors have 6 items to
  distribute.

Deliverable

✓ A 20-room run that teaches, escalates, and holds flow
✓ Two distinct enemy behaviours (smart chaser + ranged kiter) + projectiles
✓ Maze walls with collision; 3 room palettes
✓ Per-run item unlocks via door choice; smoke test green after each sub-phase

---

# Phase 6.5 — Difficulty Levels

> Added 2026-07-27 (team). Spec 018. Three selectable levels — Apprentice /
> Wizard / Archmage — scaling enemy pressure and player durability. **Item
> countdown timers never scale** (design stance: the countdown is the game's
> identity; mastery must transfer across difficulties). Independent of Phase 6
> C–E; interacts with D only in that room composition stays RunManager's job.

Goal

Let players pick their pressure level without changing the countdown puzzle.

Tasks

- Spec 018: `DifficultyResource` (+ 3 `.tres`), `GameState.difficulty` (defaults
  to Wizard = today's exact balance)
- Enemy multipliers applied at spawn (speed / cooldowns / detection, both
  archetypes); player max health + G3 i-frame duration from difficulty
- HUD hearts become count-driven (Apprentice = 7 hearts)
- Difficulty select screen after New Game (wooden-button style, keyboard nav)
- Smoke checks: Wizard = no drift; multipliers applied; countdowns identical

Deliverable

✓ Three playable difficulties selectable at New Game
✓ Wizard identical to today's balance; countdowns identical on all levels
✓ Smoke test green

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