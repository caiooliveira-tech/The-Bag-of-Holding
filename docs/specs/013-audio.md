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
  right_hand → freeze-explosion, left_hand → hand_explosions, troy → horse_explosion
- `player_damaged` → player_hit · `enemy_damaged` (new) → enemy_hit
- `player_dashed` (new) → dash · `player_kicked` (new) → kick
- `door_opened` (new) → door_open · `room_cleared` → object_collected_soundtrack
- menu: navigate → button_change, select → button_clicked

New EventBus signals added for the hooks that had none: `enemy_damaged`,
`player_dashed`, `player_kicked`, `door_opened`.

## Not yet wired (need a moment/decision)

- `clock_ticking.mp3` — likely the item countdown; needs a held-loop design.
- `shot.mp3` — no ranged attack exists (post-MVP enemy archetype).
- `freeze.mp3` — the freeze *apply* moment vs. `freeze-explosion` (the blast);
  currently only the explosion is used.
- `object_collected_soundtrack.mp3` — has "soundtrack" in the name but reads as
  a one-shot reward jingle, so it's mapped to `room_cleared` rather than looped.

## Out of Scope

- Audio bus mixing / volume sliders (a master volume option could come later).
