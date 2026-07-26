# Spec 022 — Screen Redesign + Title Screen + Level Title

## Goal

Give the front-end a cohesive art pass using the delivered `assets/screens/`
set, add a **Title Screen** (shown after a blank boot splash) and a **Level
Title** announcement when entering a room. No gameplay or options logic changes
— the same menu options, controls, and difficulty flow stay intact.

## Assets (assets/screens/ unless noted)

- `3 - Options.jpg` — dark brick wall; global backdrop for every menu screen.
- `scroll.png` — square parchment; center panel (Title), side panel (Credits),
  option panels (Options).
- `bg.png` — parchment banner (torn top+bottom); header title plate.
- `bg2.png` — hanging sign (torn bottom); the Level Title placard.
- `img-main-menu.png` — crow + bag illustration; main-menu right side.
- `assets/logo-jogo.png` — game logo; Title, menu header, Credits.

## Screens

### Title Screen (new — becomes the main scene)

- Godot boot splash: black, **no image** (`boot_splash/show_image=false`,
  `bg_color` black). Reads as "the game hasn't drawn yet", then the Title fades in.
- Brick backdrop + centered `scroll.png` with the logo and a blinking
  "PRESS ANY BUTTON TO START".
- Any key or joypad button → main menu. Menu music starts here (respecting the
  web audio-unlock gate already in AudioManager).

### Main Menu / Options / Pause / Credits (visual redesign only)

- Same structure and behavior as today (Spec 009 / 013 / 018). Rebuilt on the
  shared `MenuUI` helper: brick backdrop, parchment panels, logo, ink-on-
  parchment text. Wooden buttons (`btn_active/inactive.png`) unchanged.
- Main menu keeps: New Game → difficulty select, Options, Credits, Exit; the
  adaptive description; the crow illustration on the right.

### Level Title (new)

- On room entry the room emits `EventBus.level_entered(title)`; the `LevelTitle`
  autoload drops `bg2.png` from the top center, holds ~1.4 s, and lifts it out.
- Text from `Room.level_title` (`@export`). Non-blocking overlay (mouse ignore,
  never pauses). Empty title = no sign (e.g. test rooms that don't set one).

## Architecture

- `ui/menu/menu_ui.gd` (`class_name MenuUI`): static builders + design tokens
  (fonts, textures, ink/parchment/brick colors). Screens compose it; no per-
  screen art duplication.
- `LevelTitle` autoload mirrors the existing `DeathScreen` / `Pause` pattern:
  a CanvasLayer that reacts to an EventBus signal. Room announces, UI reacts —
  no room→UI hard reference.
- `EventBus.level_entered(title: String)` added.

## Acceptance

- Boot → blank black splash → Title fades in, prompt blinks, any button → menu.
- All four menu screens render on brick + parchment; every prior option/control
  still works (resolution, fullscreen, difficulty, pause actions, ESC routes).
- Entering room_01/02 drops a labeled sign that animates in and out without
  blocking movement or combat.
- Smoke test stays green (the sign is non-blocking; menus are unaffected).
