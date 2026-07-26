# Spec 020 - Magnetic Horseshoe

**Status:** Draft v2 (2026-07-27 — redesigned per Rafael's clarification; v1's
"pin two enemies in place" is dead)

## Goal

Fifth catalog item: the **anti-Left-Hand**. Where the rocker hand scatters, the
magnet **agglutinates** — everyone caught in the radius is sucked onto the
magnet and glued into a single cluster that moves as one.

## Design (Rafael, 2026-07-27)

- On trigger, **every character in the radius — enemies AND the player** —
  (line-of-sight gated, like all areas) is yanked to the magnet point and glued
  into a cluster.
- The cluster lasts **5 seconds** (tweakable), then releases; everyone
  separates and behaves normally again.
- **The blob moves as one.** Implementation model: each glued character keeps
  its own movement intent (enemy AI, player input), and a strong continuous
  pull toward the cluster's live centroid keeps them stuck; the blob's net
  motion is the blend of its members. An enemies-only blob chases the player
  as one unit; a blob containing the player is dragged around by player input.
- **Responds as one to subsequent items** while glued — mostly emergent from
  co-location: one Fire Orb hits the whole cluster, a freeze catches all of
  them, a knockback shoves the blob together. The magnet is the game's combo
  enabler.
- **Player caught = contact damage:** glued to enemies at zero distance, the
  player eats their melee attacks on cooldown exactly as if standing in
  contact (no special damage code — proximity does it). Dash i-frames block
  the hits but do not break the glue. Pillar 4 at its purest.

## Item Data

- `id = &"magnetic_horseshoe"`, `activation_time_seconds = 6.0` (design doc),
  graybox steel-gray; **no sheet icon yet — Design to deliver** (HUD falls
  back to the swatch).
- Effect: `MagnetAreaEffect` (new `MagicItemEffect` subclass — base framework
  untouched, same as Specs 005/011/012): `radius_tiles` (default 3.0),
  `cluster_duration_seconds` (default 5.0), pull strength tunables.

## Functional Requirements

- `MagnetAreaEffect.execute()` collects all characters in radius (enemies +
  player, LoS-gated), spawns a **`MagnetCluster`** node at the trigger point
  with the member list, and returns the members.
- Initial yank: quick tween (kick-speed feel) onto the point with small radial
  offsets so bodies visibly "stack" without perfect overlap.
- Per physics frame for 5 s: each living member is pulled hard toward the
  cluster's live centroid (applied as movement-layer force — members' own
  AI/input still contributes, walls still collide via move_and_slide).
- Members keep acting: enemies attack (melee connects on the glued player on
  cooldown; ranged still shoots), the player can still move/draw/throw/kick.
- Freeze interaction: a frozen member stops contributing intent but is still
  dragged (external force); thaw mid-cluster resumes normally.
- At 5 s the cluster frees itself (release flash for readability) and members
  disperse under their own movement again.
- Death of a member mid-cluster just removes it; empty cluster frees early.

## Acceptance Criteria

- All characters inside the radius gather onto the point; anyone outside is
  untouched.
- The blob stays together while moving (enemies-only blob advances as one
  toward the player).
- A glued player takes enemy melee hits on cooldown while the cluster lives.
- One subsequent area item hits every glued member (combo check).
- After 5 s everyone separates and moves independently; smoke green.

## Out of Scope

- A leader/scripted formation system — cohesion is emergent (centroid pull).
- Dedicated magnet SFX/icon (Design; audio reuses an existing cue for now).

## Open Questions

1. Pull radius 3 tiles (first pass — design doc said "≥ 2 tiles") and blob
   cohesion strength: tune in playtest.
2. Cluster duration 5 s confirmed as tweakable data.
