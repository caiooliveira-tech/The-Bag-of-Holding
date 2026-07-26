## Automated smoke test for the core loop (not shipped in builds).
## Section 1 (Fire Orb): draw -> throw -> explosion kills an enemy.
## Section 2 (Ursula): freeze is movement-lock only, 5 s, hits the player too.
## Pools are injected per section so the random draw can't flake the test.
extends Node

const ROOM_SCENE: PackedScene = preload("res://rooms/room_01.tscn")
const ENEMY_SCENE: PackedScene = preload("res://entities/enemies/enemy1.tscn")
const FIRE_ORB: MagicItemResource = preload("res://systems/magic_items/fire_orb.tres")
const URSULA: MagicItemResource = preload("res://systems/magic_items/right_hand_of_ursula.tres")
const LEFT_HAND: MagicItemResource = preload("res://systems/magic_items/left_hand_of_ursula.tres")
const TROY: MagicItemResource = preload("res://systems/magic_items/troy_wooden_horse.tres")
const ROOM_SCRIPT: GDScript = preload("res://rooms/room.gd")
const DOOR_SCRIPT: GDScript = preload("res://rooms/door.gd")
const AREA_DAMAGE: GDScript = preload("res://systems/magic_items/effects/area_damage_effect.gd")
const RANGED_SCENE: PackedScene = preload("res://entities/enemies/enemy2.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://entities/projectiles/enemy_projectile.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const ATOMIC: MagicItemResource = preload("res://systems/magic_items/atomic_orb.tres")
const MAGNET_EFFECT: GDScript = preload("res://systems/magic_items/effects/magnet_area_effect.gd")

var _room: ROOM_SCRIPT
var _failures: int = 0


func _ready() -> void:
	# Hitstop scales Engine.time_scale; disable it so it can't skew the test's
	# own wait timers (a slowed clock would make _wait() take real minutes).
	Juice.hitstop_enabled = false
	_room = ROOM_SCENE.instantiate() as ROOM_SCRIPT
	add_child(_room)
	_run()


func _run() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	# Run in a predictable empty room: drop any designer-painted interior walls
	# (they'd sit between the test's hardcoded blast/target positions).
	(_room.get_node("WallTiles") as TileMapLayer).clear()
	var player := get_tree().get_first_node_in_group("player") as Player
	var enemy := get_tree().get_first_node_in_group("enemies") as Enemy
	_check(player != null, "player exists")
	_check(enemy != null, "enemy exists")
	var bag := player.get_node("Bag") as Bag

	# ---- Section 1: Fire Orb ----
	bag.pool = _pool_with(FIRE_ORB)

	# Keep the enemy from interfering while we set the play up.
	enemy.freeze(30.0)
	enemy.global_position = player.global_position + Vector2(400, 0)

	await _tap("attack")
	_check(bag.has_held_item(), "item held after first Attack")

	await _wait(0.5)
	_check(bag.has_held_item(), "item still held while countdown runs")

	await _tap("move_right")
	_check(player.facing.is_equal_approx(Vector2.RIGHT), "facing snapped right")
	var throw_origin := player.global_position
	await _tap("attack")
	_check(not bag.has_held_item(), "hands empty after throw")
	await _wait(0.4)
	var item := get_tree().get_first_node_in_group("magic_items") as MagicItem
	_check(item != null and item.state == MagicItem.State.LANDED, "item landed")
	if item != null:
		var travelled := item.global_position.x - throw_origin.x
		_check(absf(travelled - GameState.tiles(2.0)) < 12.0,
				"throw travelled ~2 tiles (got %.0f px)" % travelled)
		enemy.global_position = item.global_position + Vector2(20, 0)

	await _wait(3.0)
	_check(not is_instance_valid(item) or item.is_queued_for_deletion(),
			"item despawned after trigger")
	_check(not is_instance_valid(enemy) or enemy.is_queued_for_deletion(),
			"2-hit enemy died to medium (2-hit) Fire Orb")
	_check(player.health == player.stats.max_health,
			"player out of radius took no damage (health %d)" % player.health)

	# ---- Section 2: Right Hand of Ursula ----
	bag.pool = _pool_with(URSULA)
	var enemy2 := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(enemy2)
	enemy2.global_position = player.global_position + Vector2(400, 0)
	# Pre-freeze pins it in place; Ursula must later OVERRIDE this to 5 s.
	enemy2.freeze(30.0)

	await _tap("attack")
	_check(bag.has_held_item(), "ursula drawn")
	await _tap("attack")
	await _wait(0.4)
	var ursula_item := get_tree().get_first_node_in_group("magic_items") as MagicItem
	_check(ursula_item != null and ursula_item.state == MagicItem.State.LANDED,
			"ursula landed")
	if ursula_item != null:
		# Enemy inside the blast, but out of its own melee reach of the player.
		enemy2.global_position = ursula_item.global_position + Vector2(32, -20)
		player.global_position = ursula_item.global_position + Vector2(0, 24)

	# Ursula triggers 4 s after draw; we're ~0.9 s in.
	await _wait(3.6)
	_check(player.is_frozen(), "player caught in own freeze radius")
	_check(is_instance_valid(enemy2) and enemy2.is_frozen(), "enemy frozen")

	# Movement-lock only: no movement, but acting still works.
	var pos_before := player.global_position
	await _tap("move_right")
	_check(player.global_position.distance_to(pos_before) < 1.0,
			"frozen player cannot move")
	await _tap("attack")
	_check(not bag.has_held_item(), "frozen player cannot draw a bomb (bag locked)")
	# Park the frozen enemy far away; its position doesn't affect the freeze
	# timer, which is what the unfreeze checks below measure.
	enemy2.global_position = player.global_position + Vector2(-200, 0)

	await _wait(5.0)
	_check(not enemy2.is_frozen(), "enemy unfroze after 5 s (ursula overrode pre-freeze)")
	_check(not player.is_frozen(), "player unfroze after 5 s")

	# ---- Section 3: room flow (Spec 007) ----
	# The room's only own enemy died back in section 1, so by now:
	_check(_room.state == ROOM_SCRIPT.State.CLEARED, "room CLEARED after its last enemy died")
	var doors := _room.get_node("Doors").get_children()
	var open_count := 0
	for node in doors:
		if (node as DOOR_SCRIPT).is_open:
			open_count += 1
	_check(doors.size() == 3 and open_count == 3,
			"all 3 doors opened on room clear (%d of %d)" % [open_count, doors.size()])

	# ---- Section 4: post-hit i-frames (Spec 010, G3) ----
	var jailer := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(jailer)
	jailer.global_position = player.global_position + Vector2(2000, 0)  # inert, far away
	var hp0 := player.health
	player.take_damage(1, jailer)
	_check(player.health == hp0 - 1, "enemy hit lands (health %d)" % player.health)
	player.take_damage(1, jailer)  # immediate second hit, same window
	_check(player.health == hp0 - 1, "second enemy hit blocked by i-frames")
	player.take_damage(1, player)  # own item source is not in "enemies"
	_check(player.health == hp0 - 2, "own damage ignores i-frames (health %d)" % player.health)

	# ---- Section 5: Left Hand of Ursula knockback (Spec 011) ----
	# Clear leftover enemies from earlier sections (they'd chase/attack the
	# player and pollute the shove check) and heal so nothing kills mid-test.
	await _reset_arena(player)
	bag.pool = _pool_with(LEFT_HAND)
	player.global_position = Vector2(320, 180)
	var shoved := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(shoved)
	shoved.freeze(30.0)  # no chase; knockback still applies while frozen
	# The item spawns at the bag height (~y-26) and flies 2 tiles right, so it
	# lands near (384, 154); sit the enemy just past that for a clean shove.
	shoved.global_position = Vector2(405, 154)
	await _tap("move_right")
	await _tap("attack")  # draw
	await _tap("attack")  # throw right
	var shoved_x0 := shoved.global_position.x
	await _wait(3.3)  # Left Hand activation = 3 s
	await _wait(0.3)
	_check(shoved.global_position.x > shoved_x0 + 8.0,
			"left hand shoved enemy outward (%.0f → %.0f)" % [shoved_x0, shoved.global_position.x])

	# ---- Section 6: Troy the Wooden Horse knight's-L charge (Spec 012) ----
	await _reset_arena(player)
	bag.pool = _pool_with(TROY)
	player.global_position = Vector2(120, 180)  # launch rightward from the left
	var trampled := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(trampled)
	trampled.freeze(30.0)
	trampled.global_position = Vector2(180, 154)  # in the first forward leg's path
	var trampled_hp := trampled.hits_remaining
	await _tap("move_right")
	await _tap("attack")  # draw Troy
	await _tap("attack")  # throw → charges in a tile-based L, explodes at 1st wall
	await _wait(0.5)
	_check(trampled.hits_remaining < trampled_hp, "troy damaged an enemy in its charge path")
	await _wait(2.5)
	_check(get_tree().get_nodes_in_group("magic_items").is_empty(),
			"troy exploded (despawned) on reaching a wall")

	# Troy charging over the thrower at launch must not hurt them.
	await _reset_arena(player)
	(_room.get_node("WallTiles") as TileMapLayer).clear()
	bag.pool = _pool_with(TROY)
	player.global_position = Vector2(320, 180)
	var self_hp := player.health
	await _tap("move_down")
	await _tap("attack")  # draw
	await _tap("attack")  # throw down — charges over the player
	await _wait(0.6)
	_check(player.health == self_hp, "throwing Troy over yourself does not hurt at launch")

	# ---- Section 7: interior wall-tile collision (Phase 6A) ----
	await _reset_arena(player)
	var wall_tiles := _room.get_node("WallTiles") as TileMapLayer
	var cell := Vector2i(10, 6)
	wall_tiles.set_cell(cell, 0, Vector2i(5, 5))  # solid center wall tile
	await get_tree().physics_frame
	var wall_x := float(cell.x * 32 + 16)  # cell centre (layer sits at origin)
	player.global_position = Vector2(wall_x - 60.0, float(cell.y * 32 + 16))
	Input.action_press("move_right")
	for i in 24:
		await get_tree().physics_frame
	Input.action_release("move_right")
	_check(player.global_position.x < wall_x - 12.0,
			"player blocked by interior wall tile (x=%.0f, wall=%.0f)" % [player.global_position.x, wall_x])

	# ---- Section 8: walls block explosions and enemy vision (Phase 6A) ----
	await _reset_arena(player)
	# One solid wall column at cell (10,6): world x 320..352, y 192..224.
	wall_tiles.set_cell(Vector2i(10, 6), 0, Vector2i(5, 5))
	await get_tree().physics_frame
	player.global_position = Vector2(240, 208)  # far from the blast, unaffected
	# Blast left of the wall; near enemy same side (hit), far enemy behind it (safe).
	var near := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(near)
	near.freeze(30.0)
	near.global_position = Vector2(300, 208)
	var near_hp := near.hits_remaining
	var far := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(far)
	far.freeze(30.0)
	far.global_position = Vector2(376, 208)  # right of the wall
	var far_hp := far.hits_remaining
	var blast := Node2D.new()
	get_tree().current_scene.add_child(blast)
	blast.global_position = Vector2(292, 208)
	var fx := AREA_DAMAGE.new() as MagicItemEffect
	fx.set("radius_tiles", 3.0)
	fx.set("damage_tier", 2)
	fx.set("linger_seconds", 0.05)
	fx.execute(blast)
	await get_tree().physics_frame
	_check(near.hits_remaining < near_hp, "explosion hits an enemy in the open")
	_check(is_instance_valid(far) and far.hits_remaining == far_hp,
			"explosion does NOT reach an enemy behind a wall")

	# Vision: an active enemy behind the wall can't see the player, so no chase.
	var blind := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(blind)
	blind.global_position = Vector2(400, 208)  # right of the wall
	player.global_position = Vector2(250, 208)  # left of the wall, within 5 tiles
	blind.set_active(true)
	var blind_x0 := blind.global_position.x
	for i in 14:
		await get_tree().physics_frame
	_check(absf(blind.global_position.x - blind_x0) < 6.0,
			"enemy behind a wall does not chase (no line of sight)")

	# ---- Section 9: ranged enemy + projectile (Spec 014) ----
	await _reset_arena(player)
	wall_tiles.clear()
	player.global_position = Vector2(200, 208)
	var shooter := RANGED_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(shooter)
	shooter.global_position = Vector2(360, 208)  # in sight, no wall
	var ranged_hp := player.health
	await _wait(2.5)  # it holds distance and fires; the shot reaches the player
	_check(player.health < ranged_hp, "ranged enemy's shot damaged the player")

	# A projectile is stopped by a wall before reaching the player behind it.
	await _reset_arena(player)
	wall_tiles.set_cell(Vector2i(10, 6), 0, Vector2i(5, 5))  # wall x 320..352
	await get_tree().physics_frame
	player.global_position = Vector2(280, 208)  # left of the wall
	var wall_hp := player.health
	var proj := PROJECTILE_SCENE.instantiate() as Area2D
	get_tree().current_scene.add_child(proj)
	proj.global_position = Vector2(400, 208)  # right of the wall
	proj.call("launch", Vector2.LEFT)  # flies left, toward the player through the wall
	for i in 44:
		await get_tree().physics_frame
	_check(player.health == wall_hp, "projectile stopped by a wall before the player")

	# ---- Section 10: smart chaser (Spec 015) ----
	await _reset_arena(player)
	wall_tiles.clear()
	# Separation: two chasers starting on top of each other fan apart.
	player.global_position = Vector2(320, 300)
	var c1 := ENEMY_SCENE.instantiate() as Enemy
	var c2 := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(c1)
	get_tree().current_scene.add_child(c2)
	c1.set_active(true)
	c2.set_active(true)
	c1.global_position = Vector2(320, 110)
	c2.global_position = Vector2(324, 110)
	for i in 30:
		await get_tree().physics_frame
	_check(c1.global_position.distance_to(c2.global_position) > 18.0,
			"two chasers separate instead of clumping")

	# Lunge: a chaser in range winds up then lunges and deals a hit.
	await _reset_arena(player)
	player.global_position = Vector2(320, 300)
	var lunger := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(lunger)
	lunger.set_active(true)
	lunger.global_position = Vector2(320, 244)  # just inside lunge range
	var lunge_hp := player.health
	await _wait(1.3)  # windup + lunge should land one hit
	_check(player.health < lunge_hp, "chaser's telegraphed lunge damages the player")

	# ---- Section 11: difficulty levels (Spec 018) ----
	await _reset_arena(player)
	_check(GameState.difficulty != null and GameState.difficulty.display_name == "Wizard",
			"default difficulty is Wizard (baseline)")
	# Spawn far outside detection so the probes stay inert during the checks.
	var baseline := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(baseline)
	baseline.global_position = Vector2(2000, 2000)
	# Melee cadence is the lunge recover now (Spec 015 replaced attack_cooldown).
	_check(is_equal_approx(baseline.applied_move_speed, baseline.stats.move_speed)
			and is_equal_approx(baseline.applied_lunge_recover, baseline.stats.lunge_recover),
			"Wizard-applied enemy stats equal base stats (zero drift)")
	var orb_countdown := FIRE_ORB.activation_time_seconds
	GameState.difficulty = preload("res://systems/difficulty/archmage.tres")
	var hard := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(hard)
	hard.global_position = Vector2(2000, 2000)
	_check(is_equal_approx(hard.applied_move_speed, hard.stats.move_speed * 1.15),
			"Archmage enemy speed scaled x1.15")
	_check(is_equal_approx(hard.applied_detection_tiles, hard.stats.detection_radius_tiles * 1.2),
			"Archmage detection scaled x1.2")
	_check(is_equal_approx(hard.applied_lunge_recover, hard.stats.lunge_recover * 0.8),
			"Archmage melee cooldown scaled x0.8")
	_check(is_equal_approx(FIRE_ORB.activation_time_seconds, orb_countdown),
			"item countdown unchanged by difficulty (design stance)")
	GameState.difficulty = preload("res://systems/difficulty/apprentice.tres")
	GameState.player_health = -1
	var fresh := PLAYER_SCENE.instantiate() as Player
	get_tree().current_scene.add_child(fresh)
	fresh.global_position = Vector2(2000, 1800)
	_check(fresh.health == 7 and fresh.max_health() == 7,
			"Apprentice player spawns with 7 health")
	fresh.queue_free()
	baseline.queue_free()
	hard.queue_free()
	# Let the frees process before quitting, or they report as leaked at exit.
	await get_tree().process_frame
	# Leave the session on the baseline so nothing later inherits a test level.
	GameState.difficulty = preload("res://systems/difficulty/wizard.tres")

	# ---- Section 12: Atomic Orb (Spec 021) ----
	await _reset_arena(player)
	player.global_position = Vector2(80, 300)  # well outside the 3-tile blast
	var near_atomic := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(near_atomic)
	near_atomic.global_position = Vector2(384, 208)  # 2 tiles from the blast
	var far_atomic := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(far_atomic)
	far_atomic.global_position = Vector2(500, 340)  # ~5.7 tiles: outside
	await get_tree().physics_frame
	var atomic_point := Node2D.new()
	get_tree().current_scene.add_child(atomic_point)
	atomic_point.global_position = Vector2(320, 208)
	var atomic_fx: MagicItemEffect = AREA_DAMAGE.new()
	atomic_fx.set("damage_tier", 3)
	atomic_fx.set("radius_tiles", 3.0)
	atomic_fx.set("linger_seconds", 0.05)
	atomic_fx.execute(atomic_point)
	await get_tree().physics_frame
	_check(near_atomic.hits_remaining <= 0,
			"atomic blast (heavy, 3 tiles) kills a full-health grunt outright")
	_check(is_instance_valid(far_atomic) and far_atomic.hits_remaining == far_atomic.stats.max_hits,
			"enemy outside the 3-tile radius is untouched")
	_check(ATOMIC.activation_time_seconds == 5.0 and ATOMIC.id == &"atomic_orb",
			"atomic orb data: 5 s countdown, wired id")

	# ---- Section 13: Magnetic Horseshoe (Spec 020) ----
	await _reset_arena(player)
	player.global_position = Vector2(80, 300)  # outside the pull radius
	var glued_a := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(glued_a)
	glued_a.global_position = Vector2(300, 100)
	var glued_b := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(glued_b)
	glued_b.global_position = Vector2(400, 130)
	var free_c := ENEMY_SCENE.instantiate() as Enemy
	get_tree().current_scene.add_child(free_c)
	free_c.global_position = Vector2(560, 300)  # far from the magnet point
	await get_tree().physics_frame
	var magnet_point := Node2D.new()
	get_tree().current_scene.add_child(magnet_point)
	magnet_point.global_position = Vector2(350, 100)
	var magnet_fx: MagicItemEffect = MAGNET_EFFECT.new()
	magnet_fx.set("cluster_duration_seconds", 0.9)
	magnet_fx.execute(magnet_point)
	for i in 20:
		await get_tree().physics_frame  # the yank
	_check(glued_a.global_position.distance_to(magnet_point.global_position) < 48.0
			and glued_b.global_position.distance_to(magnet_point.global_position) < 48.0,
			"magnet gathers both enemies in radius onto the point")
	_check(free_c.global_position.distance_to(Vector2(560, 300)) < 8.0,
			"enemy outside the radius is not pulled")
	for i in 20:
		await get_tree().physics_frame
	_check(glued_a.global_position.distance_to(glued_b.global_position) < 64.0,
			"glued members stay together (blob cohesion)")
	for i in 40:
		await get_tree().physics_frame  # past the 0.9 s duration
	_check(get_tree().get_nodes_in_group("magnet_clusters").is_empty(),
			"cluster releases after its duration")

	# ---- Section 14: run pool + door offers (Spec 017) ----
	await _reset_arena(player)
	player.global_position = Vector2(80, 300)
	GameState.reset_run()
	_check(GameState.run_pool.size() == 1 and GameState.run_pool[0].id == &"fire_orb",
			"new run pool starts with only the Fire Orb")
	# With a run active, draws must come from the run pool, not the bag's .tres
	# (the injected Ursula-only pool would betray a fallback draw).
	bag.pool = _pool_with(URSULA)
	var drawn_ids: Array[StringName] = []
	var catcher := func(d: MagicItemResource) -> void: drawn_ids.append(d.id)
	EventBus.item_drawn.connect(catcher)
	for i in 3:
		bag.draw_or_throw(Vector2.RIGHT)   # draw
		bag.draw_or_throw(Vector2.RIGHT)   # throw it away
		await get_tree().physics_frame
	EventBus.item_drawn.disconnect(catcher)
	_check(drawn_ids == ([&"fire_orb", &"fire_orb", &"fire_orb"] as Array[StringName]),
			"run-pool draws are Fire Orb only before any pickup")
	_check(GameState.unlock_item(URSULA), "door pickup adds a new item to the run pool")
	_check(not GameState.unlock_item(URSULA) and GameState.run_pool.size() == 2,
			"duplicate pickup is a no-op (the 'no thanks' door)")
	var offers: Array[MagicItemResource] = ROOM_SCRIPT.pick_offers(3)
	_check(offers.size() == 3 and offers[0] != offers[1]
			and offers[1] != offers[2] and offers[0] != offers[2],
			"door offers are distinct within a room")
	GameState.run_pool.clear()  # back to fallback mode; nothing runs after this
	GameState.current_room = 0
	atomic_point.queue_free()
	magnet_point.queue_free()
	await get_tree().process_frame

	# ---- Section 15: intro cutscene data (Spec 023) ----
	var intro: CutsceneResource = load("res://systems/cutscenes/intro.tres")
	_check(intro != null and intro.frames.size() == 12, "intro cutscene has 12 frames")
	_check(intro != null and ResourceLoader.exists(intro.next_scene_path),
			"cutscene next_scene_path points at a real scene")
	var art_frames := 0
	var reading_frames := 0
	for frame in intro.frames:
		if frame.text.is_empty():
			_failures += 1
			printerr("  FAIL - cutscene frame with empty text")
			break
		if frame.art != null:
			art_frames += 1
		if frame.layout != CutsceneFrameResource.Layout.DIALOGUE:
			reading_frames += 1
	_check(art_frames == 10, "10 frames carry art (first two are off-screen caws)")
	_check(reading_frames == 3, "3 reading-layout frames (the letter and the Bag)")

	if _failures == 0:
		print("SMOKE PASS: fire orb + ursula core loops OK")
	else:
		print("SMOKE FAIL: %d check(s) failed" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


## Free every enemy and top the player up, so leftover units from earlier
## sections can't chase/attack and skew (or reload) a later section.
func _reset_arena(player: Player) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		node.queue_free()
	await get_tree().process_frame
	await get_tree().physics_frame
	player.health = player.stats.max_health


func _pool_with(item_data: MagicItemResource) -> ItemPoolResource:
	var pool := ItemPoolResource.new()
	var items: Array[MagicItemResource] = [item_data]
	pool.items = items
	return pool


func _check(condition: bool, label: String) -> void:
	if condition:
		print("  ok - " + label)
	else:
		_failures += 1
		printerr("  FAIL - " + label)


func _tap(action: String) -> void:
	Input.action_press(action)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(action)
	await get_tree().physics_frame


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
