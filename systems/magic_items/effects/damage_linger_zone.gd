## Transient damage area spawned by AreaDamageEffect.
## Enforces the max-1-hit-per-target rule (team decision 2026-07-25)
## across the initial burst and the linger window, then frees itself.
class_name DamageLingerZone
extends Node2D

var _hit_amount: int = 1
var _radius_px: float = 32.0
var _time_left: float = 1.0
var _already_hit: Array[Node] = []


func setup(hit_amount: int, radius_px: float, duration: float) -> void:
	_hit_amount = hit_amount
	_radius_px = radius_px
	_time_left = duration


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius_px, Color(1.0, 0.45, 0.1, 0.35))
	draw_arc(Vector2.ZERO, _radius_px, 0.0, TAU, 32, Color(1.0, 0.6, 0.2, 0.9), 2.0)


func _physics_process(delta: float) -> void:
	apply_hits()
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()


func apply_hits() -> Array[Node]:
	var affected: Array[Node] = []
	var targets: Array[Node] = get_tree().get_nodes_in_group("enemies")
	targets.append_array(get_tree().get_nodes_in_group("player"))
	for target in targets:
		if target in _already_hit:
			continue
		var body := target as Node2D
		if body == null or body.global_position.distance_to(global_position) > _radius_px:
			continue
		_already_hit.append(target)
		affected.append(target)
		if target.is_in_group("enemies"):
			(target as Enemy).take_damage(_hit_amount)
		else:
			# Zone is not in the "enemies" group, so dash i-frames
			# correctly do NOT protect against it.
			(target as Player).take_damage(_hit_amount, self)
	return affected
