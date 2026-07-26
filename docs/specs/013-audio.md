# Spec 013 - Audio

**Status:** Implemented (2026-07-26)

## Goal

Wire the team's audio (assets/sounds/) with zero coupling: one background music
track per context and one-shot SFX fired off existing EventBus events.

## Convention (from the team)

- Files whose name contains **`soundtrack`** are looping background music.
- Every other file is an **SFX named for the moment it plays**.

## Architecture

- New autoload **`AudioManager`** owns one music `AudioStreamPlayer` (looping)
  and a small pool of SFX voices. It connects to EventBus in `_ready()` — no
  gameplay code calls audio directly except `play_music()` on scene entry and
  the menu's `play_sfx()` for navigation clicks.

## Mapping

Music (looping): `menu_soundtrack` on the menu/options/credits, `in_game_soundtrack`
on rooms.

SFX by event:
- `item_drawn` → draw_item · `item_thrown` → thrown_bomb
- `item_effect_triggered` → per item: fire_orb → fireball_explosion,
  right_hand → **freeze** (the freeze cue), left_hand → hand_explosions,
  troy → horse_explosion
- `freeze_ended` (new, thaw) → **freeze-explosion** (the un-freeze cue)
- `player_damaged` → player_hit (starts 0.08 s in, `SFX_SKIP`, to cut a silent
  lead-in) · `enemy_damaged` (new) → enemy_hit
- `room_cleared` → room_cleared · player death → player_death (on the hit) +
  game_over (on the YOU DIED screen)
- `player_dashed` (new) → dash · `player_kicked` (new) → kick
- `door_opened` (new) → door_open
- **clock_ticking** loops while ≥1 item is counting down (started on
  `item_drawn`, stopped when the last active item triggers; reset on scene
  entry so it can't stick on)
- menu: navigate → button_change, select → button_clicked

New EventBus signals added for the hooks that had none: `enemy_damaged`,
`player_dashed`, `player_kicked`, `door_opened`, `freeze_ended`.

## Web audio

Browsers block audio until a user gesture, so on web (`OS.has_feature("web")`)
the background track is held until the first key/click, then started cleanly —
music comes in on the first menu interaction instead of being silently skipped.

## Not yet wired (reserved for later, per team)

- `shot.mp3` — reserved for a future use (no ranged attack yet).
- `object_collected_soundtrack.mp3` — reserved for a future "collected" moment
  (item pick at a door / reward), not the room clear.

## Out of Scope

- Audio bus mixing / volume sliders (a master volume option could come later).
