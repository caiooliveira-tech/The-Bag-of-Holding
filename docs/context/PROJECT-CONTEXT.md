# The Bag of Holding — Master Project Context

**How to use this file:** this is a single-file consolidation of the design doc, the planning meeting, the GitHub repo's own docs, and everything discussed with Claude in chat so far — written so a Claude Code session has full grounding without hunting across five sources. Either paste this directly at the start of a session, or add it to CLAUDE.md's @ import list alongside the existing docs/context/*.md files (it doesn't replace them — those stay as the per-topic source of truth; this is the fast-start briefing).

---

## 1. Snapshot

- **Project:** The Bag of Holding — top-down roguelike, built for GMTK Jam 2026 (theme: Countdown).
- **Deadline:** jam runs July 22–26, 2026 (96 hours). Treat every scope call below as final for this build — there is no time to relitigate cut items.
- **Engine:** Godot 4.7, Forward+ renderer, GDScript only (no C#/Mono).
- **Status as of last check:** zero implementation in the repo. Spec 001 (Player Controller) is the next thing to build.
- **Team (2 fronts, working in parallel):**
  - **Design & Visual** — Silas Chosen (tiles, walls/doors, monster designs, 4-direction movement animations) and Flavio Lee (UI/HUD design, wireframes, room layouts — door and obstacle placement).
  - **Technical & Programming** — Rafael Santos and Caio Vinícius Gonçalves de Oliveira (project structure, the Fire Orb, the freeze ability, enemy AI).

---

## 2. Game Vision

Shoelace, a clumsy wizard's apprentice, must climb Violet the witch's tower to rescue his mentor, Euclidus, who was kidnapped after (in Violet's view) an overly dramatic breakup. Shoelace's only weapon is the Bag of Holding — a sack that turns anything placed inside it into a magic bomb with its own countdown and effect. The whole game is a space-vs-time puzzle: draw an item, decide when and where to throw it, and don't get caught in your own blast radius.

Explicit non-goal, stated directly in the planning meeting: the team wants to avoid being "just Bomberman" — bomb-placement is the shared DNA, but item variety (freeze, knockback, magnetize, etc.) and the draw-timer-starts-immediately rule are the intended differentiators.

---

## 3. Core Gameplay Loop

1. Player enters a room. There's a brief calm beat (room "hub" state) before enemies activate — not an empty room, just a short telegraph moment before combat starts.
2. Press Attack → draw one random item from the Bag pool. The countdown starts the instant the item is drawn — not when it's thrown.
3. Hold the item (follows the player, raised) or press Attack again to throw it (default range: 2 tile-units) in the facing direction.
4. The countdown runs identically whether held, in flight, or landed — there is no safe state. It can be redirected further with a kick (Apprentice Boot special, +5 tile-units) once thrown/landed.
5. When the countdown hits zero, the effect triggers and can hit the player as well as enemies. Dash grants invulnerability to enemy attacks only — never to the player's own item effects.
6. Clear all enemies in the room → all doors open, each with a power-up choice in front of it → player picks one door/power-up → proceeds to the next room. Loop repeats, climbing the tower.

---

## 4. Confirmed Mechanics & Exact Numbers

### Movement & Player Controller

- Free movement, not grid-locked — confirmed explicitly in the planning meeting ("é geralzão... movimento livre"). Tiles are a measurement unit for ranges/radii and a construction unit for level geometry — they are not a movement grid the player snaps to.
- **1 tile = 32 pixels** (decided 2026-07-25). All tile-unit distances (throw range, radii, kick distance) convert at this rate.
- 8-directional movement + dash/dodge. Dash grants i-frames vs. enemy damage only.
- **Aiming/facing is movement-direction-based** (Zelda/gamepad-style), not mouse-based — decided 2026-07-25, resolving the former Spec 001 blocker. Facing = last non-zero movement direction; it determines throw and kick direction.

### Attack / Bag / Item State

- Single Attack input handles draw → hold → throw (see Spec 002).
- Default throw distance: 2 tile-units in the facing direction.
- Apprentice Boot (starting special): kick for 1 damage to an enemy, OR kick an already-thrown/landed item 5 tile-units further.
- HUD shows only the currently-held item — no "next item" preview. This was explicitly discussed (Tetris-style next-item queue) and rejected for v1 to keep the mechanic focused on the immediate decision. Can be revisited later if playtesting shows it helps.

### Damage System (confirmed, with real numbers from the meeting)

- Discrete hit-count, not percentage/HP-bar. Rejected explicitly because fractional/percentage damage behaves inconsistently across diagonals, frame timing, and is harder to communicate to the player.
- Enemies have a small fixed hit count: weak enemies die in 1 hit, tougher enemies take 2–4 hits. Team's stated ceiling: don't give any single enemy more than 3–4 hits — scale difficulty by enemy count in a room, not individual toughness.
- **Player health: Shoelace has 5 hits. Enemy attacks deal 1 hit each** (decided 2026-07-25).
- Bombs/items have an implicit "power tier" (e.g. Fire Orb = medium) that determines how many hits worth of damage they deal.
- Damage feedback is entirely color/blink-based (see Section 6) — no HP bars anywhere, on enemies or the player.

### MVP Item Catalog (only these two are in scope for the jam)

**Fire Orb**

- Appearance: a fire lamp/lantern.
- effect_type: area damage, medium tier.
- radius_tiles: 1 (all directions).
- activation_time_seconds: 3 (from draw, not from throw/landing).
- Damage lingers for 1 second after trigger. **The lingering window deals at most 1 hit total per target** (decided 2026-07-25) — it does not tick repeatedly.

**The Right Hand of Ursula**

- Appearance: a mummified right hand with a sigil on its palm.
- effect_type: freeze area (movement-lock).
- radius_tiles: 1.
- activation_time_seconds: 4.
- freeze_duration_seconds: 5.
- Resolved in the meeting (re-confirmed 2026-07-25): freeze prevents movement only. A frozen character (including the player, if caught in their own effect) can still be attacked — and can still attack — while frozen. It is crowd control, not a full action-lock.

### Deferred items (explicitly out of scope for this jam — do not build)

- **Troy the Toy Horse** — explicitly punted mid-meeting ("let's discuss this on Saturday night or Sunday" — i.e., after the jam). Moves forward in an L-shaped pattern, damages on contact, despawns at the wall.
- **The Left Hand of Ursula** — knockback (throws enemies toward the nearest wall), radius_tiles: 1, activation_time_seconds: 3, knockback distance 6 tiles.
- **Magnetic Horseshoe** — pulls the two nearest enemies (≥2 tiles away) and sticks them together, activation_time_seconds: 6. Flagged by the team itself as complex/balance-heavy — explicitly deferred.
- **Atomic Orb** — heavy-tier upgrade of Fire Orb, radius_tiles: 3, activation_time_seconds: 5, 2s damage linger.
- **Specials beyond Apprentice Boot:** Amulet of Harris (2x item-timer speed while held), Amulet of Atuin (2x item-timer duration while held), The Broken Hourglass (freezes item timers while held), Visible Time Glasses (passive numeric countdown display — directly contradicts the no-numbers UI rule for MVP, explicitly a stretch/toggleable idea, not default).
- Special-item equip UI/slots — discussed, explicitly deferred ("acho que não" — not now, maybe later).

---

## 5. Enemy AI (MVP)

- Two visual archetypes exist in design ("pink" ranged, "blue" melee), but behavior is simplified to one shared pattern for the jam: on player proximity, approach and attack.
- Detection: proximity-based only, roughly a 5-tile radius. No line-of-sight or wall-blocking checks for MVP — explicitly decided as unnecessary complexity given the room sizes in play.
- Build enemy behavior as a generalized, parameterized base (speed, attack range, damage) rather than one-off scripts per type — ranged vs. melee should end up being a parameter difference, not separate code, so it's cheap to add the second archetype later if time allows.
- Room variation (different patrol/aggro patterns per room) was raised as a nice-to-have for later difficulty tuning, not required for MVP.

---

## 6. UI / HUD & Feedback Rules

- Layout inspired by Brawl Stars / Bomberman: central screen area reserved exclusively for gameplay; all HUD elements pinned to the edges, never overlapping the play area.
- Damage feedback: color/blink only — an enemy flashes red on each hit, turns a stronger/more saturated red as it nears its last hit, and simply disappears on death. No HP bars, no numbers.
- Bomb/item countdown feedback: reuse the same blink language — an item blinks faster as its activation_time_seconds approaches zero. This applies even while the item is still held, not just once thrown — it's meant to trigger urgency in the player's hand, not just on the ground.
- Held-item indicator: a dedicated HUD slot shows only the current item (see Section 4 — no next-item preview for v1).
- Player health: a simple heart/segment display at a screen edge; design not fully locked, treat as low-risk/easy to slot in once Design front delivers it. (5 hearts/segments — see Section 4.)
- Room progression indicator (e.g. "Room 2 of N") was sketched as a nice future addition — not required for MVP.

---

## 7. Art & Audio Direction

- Gray-box first. Validate every mechanic with primitive shapes before final art lands — explicitly agreed as the working method, not just a fallback.
- Tile assets (walls, doors) must be modular: mid-piece + corner/edge variants that tile seamlessly in both directions. This is Design front's responsibility (Silas); does not block programming work.
- Audio bar for the jam is intentionally low: one ambient/mysterious dungeon loop is enough to cover most of the "needs music" feeling; the rest is sound effects only. Full music production is explicitly a post-jam concern, not a jam blocker.
- **No generative AI for art or audio, at all** — team-wide, non-negotiable decision, discussed at length in the meeting on both ethical and practical grounds (Steam's AI-content disclosure requirement was cited as a real reputational/discoverability risk). This does not apply to AI-assisted coding (Claude Code), which the project already relies on. See docs/decisions/ADR-001-no-generative-ai-assets.md.

---

## 8. Architecture & Coding Conventions

(Full detail lives in docs/context/game-architecture.md and docs/context/godot-standards.md — summarized here for quick reference.)

- Composition over inheritance; one responsibility per script; ~250 line soft cap per script.
- Static typing everywhere (`var health: int = 100`, typed signatures).
- Config/tunables live on exported Resources, never as magic numbers.
- Signals flow outward ("I changed"), direct calls flow inward ("do this"). Avoid signal chains more than two hops — route through a shared EventBus autoload instead.
- Any node with more than ~3 mutually exclusive behavior modes gets an explicit state machine, not a bundle of booleans.
- Autoloads (GameState, EventBus, SaveManager, AudioManager) never hold hard references to freeable scene nodes (player, enemies, projectiles) — communicate via signals.
- Folder-by-feature, not by node type: a system's scene, script, and resources live together (see game-architecture.md for the full tree).
- Cache node references in `_ready()`; never `get_node()`/`$` inside `_process()`/`_physics_process()`.

---

## 9. Team Workflow

- Communication: migrating off WhatsApp to an async-first setup — Discord (or Slack) + shared Google Docs, decided but not yet fully live; WhatsApp is the temporary fallback until that's set up.
- Task tracking: Trello or ClickUp under evaluation (Rafael to decide).
- Development approach: documentation-first, spec-driven. Every gameplay feature gets a spec under docs/specs/ before implementation; architectural decisions get an ADR under docs/decisions/; progress is tracked in docs/context/progress-tracker.md. This file, and the per-topic context docs, are what CLAUDE.md auto-loads into every AI session — keep them current as decisions change.
- AI's role, explicitly stated by the team: "Nada do que a gente tá fazendo, a IA só vai executar" — the AI assistant implements against specs the team has already thought through; it does not originate design decisions, especially not for art/audio (Section 7).

---

## 10. Current Repo Status

- project.godot exists; engine config set (Godot 4.7, Forward+).
- No entities/scenes/scripts implemented yet — genuinely starting from zero.
- docs/context/game-overview.md and art-direction.md — now filled in (previously empty headers; this was the main gap blocking AI-assisted sessions from having real context).
- docs/specs/001-player-controller.md, 002-bag-system.md, 003-magic-item-framework.md — expanded from stubs to full spec-template detail.
- docs/specs/004-fire-orb.md, 005-right-hand-of-ursula.md — new, cover the two MVP items concretely.
- docs/decisions/ADR-001-no-generative-ai-assets.md — new, formalizes Section 7's AI-ethics stance as an ADR.

---

## 11. Resolved vs. Still-Open Questions

**Resolved (do not re-litigate these):**

- Movement is free, not grid-snapped; tiles are a measurement/construction unit only. 1 tile = 32 px.
- **Input/aiming scheme: movement-direction-based facing** (Zelda/gamepad-style). Facing = last non-zero movement direction. Decided 2026-07-25 — this was the last Spec 001 blocker.
- Damage is discrete hit-count (1–4 per enemy), not percentage/HP. Player has 5 hits; enemy attacks deal 1 hit.
- Fire Orb's 1-second damage linger deals at most 1 hit total per target — no repeated ticks.
- Freeze (Right Hand of Ursula) is movement-lock only; frozen entities can still act/be acted upon.
- HUD shows only the current held item, not a next-item preview.
- MVP items are exactly two: Fire Orb + Right Hand of Ursula. Everything else in the catalog is deferred.
- Enemy AI is one shared approach-and-attack pattern for MVP, no line-of-sight logic.
- No generative AI for art/audio, ever, for this project.

**Still open — needs a team decision before coding starts:**

- None. All previously open questions were resolved on 2026-07-25.

---

## 12. Recommended Immediate Next Step

1. ~~Resolve the controls open question~~ — done (movement-direction facing).
2. Commit this file plus the spec package to the repo.
3. Implement Spec 001 (Player Controller) — movement, dash, facing, Attack input wiring to the (not-yet-built) Bag system.
4. Then Spec 002 (Bag System) → Spec 003 (Magic Item Framework) → Spec 004 (Fire Orb) end-to-end, validated with gray-box shapes before any art lands — this is the fastest path to a demonstrably fun build.
5. Spec 005 (Right Hand of Ursula) once the framework is proven on one item.
