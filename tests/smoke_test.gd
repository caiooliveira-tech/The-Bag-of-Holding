## Automated smoke test for the core loop (not shipped in builds).
## Section 1 (Fire Orb): draw -> throw -> explosion kills an enemy.
## Section 2 (Ursula): freeze is movement-lock only, 5 s, hits the player too.
## Pools are injected per section so the random draw can't flake the test.
extends Node

const ROOM_SCENE: PackedScene = preload("res://rooms/room_01.tscn")
const ENEMY_SCENE: PackedScene = preload("res://entities/enemies/enemy.tscn")
const FIRE_ORB: MagicItemResource = preload("res://systems/magic_items/fire_orb.tres")
const URSULA: MagicItemResource = preload("res://systems/magic_items/right_hand_of_ursula.tres")

var _failures: int = 0


func _ready() -> void:
	add_child(ROOM_SCENE.instantiate())
	_run()


func _run() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
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
	_check(bag.has_held_item(), "frozen player can still act (drew an item)")
	await _tap("attack")  # throw it away; its own trigger must hit nobody
	# Move the (frozen) enemy clear of that second blast — frozen position
	# doesn't affect its freeze timer, which is what we're measuring.
	enemy2.global_position = player.global_position + Vector2(-200, 0)

	await _wait(5.0)
	_check(not enemy2.is_frozen(), "enemy unfroze after 5 s (ursula overrode pre-freeze)")
	_check(not player.is_frozen(), "player unfroze after 5 s")

	if _failures == 0:
		print("SMOKE PASS: fire orb + ursula core loops OK")
	else:
		print("SMOKE FAIL: %d check(s) failed" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


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
