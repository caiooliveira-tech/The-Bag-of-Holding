# Spec 023 - Cutscenes (system + intro)

**Status:** Implemented (2026-07-28, branch `feature/cutscenes`, PR #7)

Implementation notes: the three delivered PNGs were imported to
`assets/cutscenes/` as planned. Dialogue layout tuned against the storyboard
after a screenshot pass — the banner now bleeds off the bottom edge at 1160 px
wide and the art perches on it (a centered 880 px banner left black margins the
mockups don't have); the `[ESC] SKIP` hint moved to the top-right because the
banner swallowed it at the bottom. Open questions 1 and 2 shipped as proposed
(once per launch via `GameState.intro_seen`; difficulty select first).

**Builds on:** Spec 022 (screen redesign) — reuses `MenuUI` tokens (Dellas fonts,
ink/parchment colors) and the delivered `assets/screens/` art, so the cutscene
looks like the rest of the front-end with no per-screen art duplication.

## Goal

A reusable, **data-driven cutscene player** plus the game's **intro cutscene**:
Eliza the raven arrives at dawn with Euclidus's letter and the Bag of Holding,
and Shoelace decides to climb the tower. Story context turns the MVP from "a
room with bombs" into the game the design doc describes.

## Narrative Description

Twelve frames (storyboard delivered by Design 2026-07-28), in two visual modes:

- **Dialogue frames** — black background, a character/prop illustration above,
  and the torn parchment banner (`bg.png`) across the bottom with centered ink
  text. Speech and Shoelace's reactions.
- **Reading frames** — no banner: the prop (letter, then Bag) fills one side of
  the screen while Euclidus's written words sit on the other side in white
  text. Reads as *the player reading over Shoelace's shoulder*.

### Frame list (shipping copy — proofread here, not in the mockups)

| # | Layout | Art | Text |
| --- | --- | --- | --- |
| 1 | Dialogue | *(none)* | CACAW! CACAW! |
| 2 | Dialogue | *(none)* | WHAT'S ALL THIS RUCKUS AT THIS TIME IN THE MORNING? |
| 3 | Dialogue | Raven | CACAW! CACAW! |
| 4 | Dialogue | Raven | OH, IT'S MY MASTER'S RAVEN. WHAT IS IT ELIZA? DID YOU ESCAPE AGAIN? |
| 5 | Dialogue | Raven | YOU HAVE A LETTER, AND... AN OLD BAG?? |
| 6 | Reading (art left) | Letter | MY DEAR SHOELACE. / SHE HAS FOUND ME. AND LOCKED ME. IN MY OWN TOWER. / I NEED HELP. I CAN'T DO MAGIC ANYMORE. / PLEASE COME TO THE TOWER AND HELP ME. |
| 7 | Reading (art right) | Bag | THIS IS MY BAG OF HOLDING. / USE IT. WHATEVER YOU PUT IN IT WILL STAY THERE UNTIL YOU DIE. EVEN IF YOU TAKE IT OUT. / USE IT TO TURN MY MAGIC OBJECTS INTO WEAPONS. BUT BEWARE THEIR DANGER. |
| 8 | Reading (art right) | Bag | AND BEWARE OF HER. SHE IS EVIL AND VERY, VERY ANGRY. / TRUST NO ONE IN THE TOWER. MADNESS IS RUNNING FREE. / TRY NOT TO DIE. / YOUR MASTER, EUCLIDUS |
| 9 | Dialogue | Bag | MASTER EUCLIDUS IS TRAPPED? WHO IS SHE??? |
| 10 | Dialogue | Bag | WHAT DO I DO??? |
| 11 | Dialogue | Raven | CACAW! CACAW! |
| 12 | Dialogue | Raven | YOU'RE RIGHT, ELIZA. I HAVE NO CHOICE. I'LL TAKE THE BAG TO THE TOWER AND HOPE FOR THE BEST. |

Frames 1–2 deliberately show no art: the caw comes from off-screen, so the
raven's entrance on frame 3 lands.

## Assets

Already in the repo:

- `assets/screens/bg.png` — torn parchment banner = the dialogue box (same
  asset Spec 022 uses for header plates).
- `assets/fonts/Dellas-*` — ink lettering, via `MenuUI`.

**Missing — to import at implementation** (delivered by Design, currently only
outside the repo). Target `assets/cutscenes/`:

| Source | Target | Used by |
| --- | --- | --- |
| `CORVO.png` (1800×1269) | `assets/cutscenes/raven.png` | frames 3–5, 11–12 |
| `CARTA (1).png` (1680×1353) | `assets/cutscenes/letter.png` | frame 6 |
| `BAG.png` (2128×1857) | `assets/cutscenes/bag.png` | frames 7–10 |

`img-main-menu.png` (crow **and** bag together) can't be reused — the cutscene
needs them separately. No audio asset exists for the caw (see Open Questions).

## Functional Requirements

- **Advance:** any key / joypad button / click. Text reveals with a typewriter
  effect; a press while revealing **completes the current frame instantly**, the
  next press advances — never punishes an eager player.
- **Skip:** `ESC` (and Start) skips the whole cutscene straight to the next
  scene. A small persistent hint reads `[ESC] SKIP`.
- Frame transitions cross-fade briefly; art slides/fades in rather than popping.
- The player cannot act, be damaged, or pause during a cutscene — it is a
  standalone scene, not an overlay (nothing gameplay-side is running).
- **Flow:** Main Menu → New Game → Difficulty Select → **intro cutscene** →
  `room_01`. Skipping lands on `room_01` identically. Every New Game plays it
  (no save system to remember "seen"; see Open Questions).
- Music: the menu track keeps playing through the cutscene; `room_01` switches
  to the in-game track as it already does. Web audio-unlock behavior unchanged.
- Optional per-frame SFX hook (`sfx: StringName` played through AudioManager on
  frame entry) — unused until Design delivers a caw.

## Architecture

Data-driven, mirroring how items and difficulties are authored:

- **`CutsceneFrameResource`** (`systems/cutscenes/`): `text: String`,
  `art: Texture2D`, `layout: Layout` (`DIALOGUE`, `READING_LEFT`,
  `READING_RIGHT`), `sfx: StringName`. Data + validation only, no node deps.
- **`CutsceneResource`**: `frames: Array[CutsceneFrameResource]` +
  `next_scene_path: String`. One `.tres` per cutscene (`intro.tres`).
- **`ui/cutscene/cutscene_player.tscn|gd`**: a `Control` scene that takes a
  `CutsceneResource` (exported), renders frames, handles input, then
  `change_scene_to_file(next_scene_path)`. Presentation only — it never touches
  gameplay state.
- Text/typography via `MenuUI` tokens (Spec 022); layouts built with containers
  so a longer line reflows instead of needing manual nudging.

Adding a cutscene later (e.g. the ending after Violet) is then **pure data**:
author a `.tres` and point a scene at it — no new code, the same lesson Spec 003
taught with magic items.

## Acceptance Criteria

- New Game → difficulty → the 12 frames play in order with the right art and
  layout per the table; text matches the copy above exactly.
- Typewriter completes on first press, advances on the next; `ESC` skips to
  `room_01` from any frame.
- Reading frames show no dialogue banner; dialogue frames 1–2 show no art.
- Cutscene never blocks or breaks the run: after it (skipped or watched) the
  player spawns in `room_01` with the run pool freshly reset.
- Smoke test stays green (cutscene is outside the gameplay scenes it exercises);
  add a check that the intro `.tres` loads with 12 frames and a valid next scene.

## Out of Scope

- **Ending cutscene** — the system supports it; content/storyboard is a later
  data-only addition.
- Per-frame parallax/animated art, voice acting, localization, save-based
  "already seen" tracking, in-run story beats between floors.

## Open Questions

1. **Replay every run?** No save system, so the intro plays on every New Game.
   Acceptable for the jam, or gate it behind a session flag (plays once per
   launch)? *Proposal: session flag — respects repeat testers and jam judges.*
2. **Placement:** difficulty select before or after the cutscene? *Proposal: as
   specced (difficulty first) so the last thing before play is the story beat.*
3. **Caw SFX** and an optional quieter cutscene music track — Design.
4. Frame 6's letter shows Euclidus's handwriting art; the readable text sits
   beside it. Confirm that's intended rather than text over the parchment.
