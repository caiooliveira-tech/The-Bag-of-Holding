## Automated smoke test for the Phase 2 core loop (not shipped in builds).
## Simulates inputs: draw -> face right -> throw -> explosion kills a frozen
## enemy standing on the landing spot. Prints SMOKE PASS/FAIL and quits.
extends Node

const ROOM_SCENE: PackedScene = preload("res://rooms/room_01.tscn")

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

	# Keep the enemy from interfering while we set the play up.
	enemy.freeze(30.0)
	enemy.global_position = player.global_position + Vector2(400, 0)

	# Draw.
	await _tap("attack")
	_check(bag.has_held_item(), "item held after first Attack")

	# Countdown must run while held.
	await _wait(0.5)
	_check(bag.has_held_item(), "item still held while countdown runs")

	# Face right, then throw.
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
		# Park the frozen enemy on the blast spot.
		enemy.global_position = item.global_position + Vector2(20, 0)

	# Wait out the rest of the 3 s countdown (plus margin).
	await _wait(3.0)
	_check(not is_instance_valid(item) or item.is_queued_for_deletion(),
			"item despawned after trigger")
	_check(not is_instance_valid(enemy) or enemy.is_queued_for_deletion(),
			"2-hit enemy died to medium (2-hit) Fire Orb")
	_check(player.health == player.stats.max_health,
			"player out of radius took no damage (health %d)" % player.health)

	if _failures == 0:
		print("SMOKE PASS: core loop draw/hold/throw/countdown/explosion OK")
	else:
		print("SMOKE FAIL: %d check(s) failed" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


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
