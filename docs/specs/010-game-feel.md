# Spec 010 - Game Feel (Juice)

**Status:** Implemented (G1–G5, 2026-07-26)

## Goal

Add impact and readability to the existing, functional combat loop through
"juice" — camera shake, hitstop, tweened reactions, particles — without
changing gameplay values. Every effect reinforces the pillars: readability
without numbers (danger/damage/state read at a glance), friendly-fire
clarity (you always know where a bomb lands and blows), and fast combat
(feedback is snappy, never blocks input for long).

## Design Principles (apply to every phase)

- **Feedback is decoupled.** Reactions listen to `EventBus` (or a local
  signal) and drive `modulate`/`scale`/particles — no feedback code lives in
  gameplay decision logic. UI never gains gameplay logic (game-architecture.md).
- **No balance drift.** The item countdown, throw distance (2 tiles), radii,
  hit counts, and speeds are untouched. Juice is visual/temporal polish only.
  The lone exception is post-hit i-frames (Phase G3) — a real design change,
  flagged for a team call.
- **Graybox-safe.** Effects use `modulate`, `scale`, tweens and primitive
  particles — they work on the current sprites and need no new art from Design.
- **Tunable.** Magnitudes/durations are exported constants or Resource fields,
  never magic numbers buried in logic (godot-standards.md).
- **Freeze ≠ impact.** Crowd-control (Ursula) must feel different from damage:
  it gets a soft "zoom punch" and frost particles, not a violent shake.

## EventBus additions (small, additive)

Feedback consumers need to tell an explosion from a freeze and know how hard a
hit landed. Extend the existing signals rather than reaching into nodes:

- `item_effect_triggered(item_id, position)` → add an `effect_kind: StringName`
  (`&"area_damage"` / `&"freeze_area"`) so the camera/VFX pick a profile
  without hardcoding item ids.
- New `enemy_died(enemy)` already exists (carries the node) — VFX reads its
  position/color from the node before it frees.
- New `hit_landed(target, amount, source_position)` (optional, Phase G3/G4)
  for knockback direction + hitstop, if per-hit data is cleaner than reusing
  `player_damaged`.

All additions are backward-compatible; existing listeners ignore new args.

---

## Phased Roadmap

Ordered by impact-per-effort. Each phase ends on a playable build and a green
smoke test (juice must never break the core loop). Phases are independent —
any can be cut without blocking the others.

### Phase G1 — Impact Core (highest priority) — **Implemented 2026-07-26**

The combat-transforming trio. One sitting.

- **Camera shake (trauma-based).** A script on the room Camera2D holds
  `trauma` (0..1) that decays each frame; per-frame offset =
  `max_offset * trauma²` with a random/noise direction. Listens on EventBus:
  explosion +0.5, player hit +0.3, enemy death +0.2. Trauma stacks and
  self-clears. Freeze does NOT shake (see Phase G2).
- **Enemy death pop.** On `enemy_died`: white flash → scale 1.0→1.3 over ~80 ms
  → free, emitting ~6 one-shot square `CPUParticles2D` in the enemy's colour,
  plus ~30 ms hitstop. Replaces the current silent `queue_free`.
- **Player damage pack:** hitstop (~50 ms at `Engine.time_scale = 0.05`,
  restored via a real-time timer), a short knockback (~0.5 tile) away from the
  source, and a red screen-edge vignette flash (CanvasLayer) + a scale "pop"
  on the heart that empties.

**Deliverable:** hits and kills feel physical; the screen reacts to violence.

### Phase G2 — Item Motion & Landing Read — **Implemented 2026-07-26**

Sells the core mechanic and friendly-fire clarity.

- **Landing marker.** While an item is thrown/in flight, show a shadow/target
  reticle at its landing cell so the player reads "it lands THERE" instantly.
- **Visual arc + bounce.** The item's real position keeps its linear 0.18 s
  tween (countdown/gameplay unchanged — no safe state); the *visual child*
  offsets on a parabola (`-height * sin(π·t)`) and does 2 decaying bounces with
  squash & stretch on landing. Kicked items also spin in flight.
- **Freeze feel (distinct from damage):** on a `freeze_area` trigger, a subtle
  camera "zoom punch" (2.0→2.06→2.0 over ~0.15 s) instead of shake, an
  expanding frost ring, and ice particles; the frozen tint "cracks" on thaw.

**Deliverable:** throws and kicks arc and land readably; freeze reads as cold, not force.

### Phase G3 — Player Survivability Feedback (contains a design decision) — **Implemented 2026-07-26 (i-frames = 0.5s, tunable)**

- **Post-hit i-frames (~0.5 s)** with the sprite blinking in alpha, applied to
  ENEMY damage only — the player's own item effects always connect (pillar 4).
  **This changes difficulty** (today two synced enemies drain HP unfairly
  fast). Needs a team call before merge — recommended, but it is not pure juice.
- Dash already has enemy-only i-frames; unify the invulnerability handling so
  dash and post-hit share one code path.

**Deliverable:** taking a hit is survivable and legible; no more instant double-taps.

### Phase G4 — Action Personality (cheap, high-charm) — **Implemented 2026-07-26**

Small tweens on the most-repeated actions.

- **Draw overshoot:** drawn item springs from the bag scale 0→1.2→1.0 (elastic).
- **Explosion ring:** a quick expanding ring that fades in ~100 ms, separating
  the "BOOM" instant from the 1 s linger area.
- **Urgency pulse:** near 0 s, the item pulses scale together with its blink —
  urgency reads better on real sprites than modulate alone.
- **Dash ghost trail:** 2–3 fading sprite copies during the dash.

**Deliverable:** the moment-to-moment actions have character.

### Phase G5 — Optional Atmosphere (stretch) — **Implemented 2026-07-26 (subset)**

- Subtle idle bob on player/enemies, door-open shake + dust, screen-clear
  flourish on room clear, tiny controller rumble hooks (gamepad already bound).

**Deliverable:** ambient life; safe to cut entirely.

---

## Architecture Notes

- One reusable `CameraShake`/`juice` helper on the Camera2D, EventBus-driven —
  rooms already own a Camera2D each.
- Particles via `CPUParticles2D` one-shots (jam-safe, no shader/material setup);
  pool only if the profiler shows a hotspot (perf rule — validate first).
- Hitstop uses `Engine.time_scale` + a `Timer` with `process_mode = ALWAYS`
  (real-time) so the restore fires while the game is slowed.
- Item arc/bounce lives on the item's visual child, never on its collision/
  world position — the countdown and effect timing stay identical across
  held/thrown/landed (Spec 003 invariant).

## Acceptance Criteria (per phase)

- The core loop still works and the smoke test stays green after each phase.
- No gameplay value changed except Phase G3's i-frames (explicitly decided).
- Explosion shakes; freeze does not. Player self-damage is never blocked by
  dash or post-hit i-frames.

## Out of Scope

- Audio/SFX (separate pass; the shake/particle hooks are where SFX will attach).
- Final art-authored VFX from Design (these are code-driven placeholders that
  real sprite VFX can later replace on the same signals).
- Screen transitions between rooms (Phase 4 handles room change already).
