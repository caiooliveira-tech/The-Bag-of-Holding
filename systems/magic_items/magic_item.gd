## Behavior half of a magic item (Spec 003): countdown + held/thrown/landed
## state. The countdown is fully state-independent — there is no safe state.
class_name MagicItem
extends Node2D

signal countdown_started
signal item_landed(item_id: StringName, position: Vector2)
signal item_kicked(item_id: StringName, new_position: Vector2)
signal effect_triggered(item_id: StringName, position: Vector2)
signal effect_resolved(item_id: StringName, affected_targets: Array[Node])

enum State { HELD, THROWN, LANDED }

const FLIGHT_TIME: float = 0.18
const BLINK_MIN_HZ: float = 2.0
const BLINK_MAX_HZ: float = 10.0
const GRAYBOX_RADIUS_PX: float = 10.0
# Game feel (Spec 010, G2): cosmetic hop height and kick spin.
const ARC_HEIGHT_PX: float = 22.0
const KICK_SPIN_TURNS: float = 2.0
const MARKER_PADDING_PX: float = 12.0
const LANDING_MARKER: GDScript = preload("res://systems/juice/landing_marker.gd")

var data: MagicItemResource
var state: State = State.HELD

var _elapsed: float = 0.0
var _triggered: bool = false
# Sprite2D when the resource has an appearance texture, Polygon2D graybox
# otherwise — the blink only needs `modulate`, so CanvasItem covers both.
var _visual: CanvasItem
var _marker: Node2D


func setup(item_data: MagicItemResource) -> void:
	data = item_data


func _ready() -> void:
	add_to_group("magic_items")
	_build_graybox_visual()
	_play_draw_overshoot()
	countdown_started.emit()


## The draw springs out of the bag (Spec 010, G4): 0 → 1.2 → 1.0, elastic.
func _play_draw_overshoot() -> void:
	_visual.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.2, 1.2), 0.12) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual, "scale", Vector2.ONE, 0.08)


func _process(delta: float) -> void:
	if _triggered:
		return
	_elapsed += delta
	_update_blink()
	if _elapsed >= data.activation_time_seconds:
		_trigger()


func time_remaining() -> float:
	return maxf(data.activation_time_seconds - _elapsed, 0.0)


func is_kickable() -> bool:
	return state != State.HELD and not _triggered


func throw(direction: Vector2) -> void:
	if state != State.HELD or _triggered:
		return
	state = State.THROWN
	reparent(get_tree().current_scene)
	_fly(direction, GameState.tiles(2.0), 0.0)


## Apprentice Boot redirect: +5 tiles, countdown untouched.
func kick(direction: Vector2) -> void:
	if not is_kickable():
		return
	state = State.THROWN
	_fly(direction, GameState.tiles(5.0), KICK_SPIN_TURNS)
	item_kicked.emit(data.id, global_position)


## The item's real position tracks a straight line to the landing spot (so the
## countdown/effect are unchanged — no safe state). Only the visual child hops
## on a parabola and spins; a marker previews the blast footprint mid-flight.
func _fly(direction: Vector2, distance: float, spin_turns: float) -> void:
	var dir := direction.normalized()
	var target := global_position + dir * distance
	# Stop short of walls so items never land inside geometry.
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target, 1)
	var hit := space.intersect_ray(query)
	if not hit.is_empty():
		target = (hit.position as Vector2) - dir * GRAYBOX_RADIUS_PX
	_spawn_landing_marker(target)
	var start := global_position
	var tween := create_tween()
	tween.tween_method(_apply_flight.bind(start, target, spin_turns), 0.0, 1.0, FLIGHT_TIME)
	tween.tween_callback(_on_flight_finished)


func _apply_flight(t: float, start: Vector2, target: Vector2, spin_turns: float) -> void:
	global_position = start.lerp(target, t)
	var arch := sin(PI * t)
	_visual.position.y = -ARC_HEIGHT_PX * arch
	# Slight vertical stretch at the top of the arc reads as "in the air".
	_visual.scale = Vector2(1.0 - 0.12 * arch, 1.0 + 0.18 * arch)
	if spin_turns != 0.0:
		_visual.rotation = t * TAU * spin_turns


func _spawn_landing_marker(target: Vector2) -> void:
	if _marker != null and is_instance_valid(_marker):
		_marker.queue_free()
	var radius_tiles: float = data.effect.preview_radius_tiles()
	if radius_tiles <= 0.0:
		return
	_marker = LANDING_MARKER.new() as Node2D
	get_tree().current_scene.add_child(_marker)
	_marker.global_position = target
	_marker.setup(GameState.tiles(radius_tiles) + MARKER_PADDING_PX, data.graybox_color)


func _on_flight_finished() -> void:
	if _triggered:
		return
	state = State.LANDED
	if _marker != null and is_instance_valid(_marker):
		_marker.queue_free()
	_bounce()
	item_landed.emit(data.id, global_position)


## Two decaying squash-and-stretch bounces on the visual when the item settles.
func _bounce() -> void:
	_visual.rotation = 0.0
	_visual.position.y = 0.0
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.25, 0.75), 0.05)
	tween.tween_property(_visual, "scale", Vector2(0.9, 1.1), 0.06)
	tween.tween_property(_visual, "scale", Vector2(1.05, 0.95), 0.05)
	tween.tween_property(_visual, "scale", Vector2.ONE, 0.05)


func _trigger() -> void:
	_triggered = true
	if _marker != null and is_instance_valid(_marker):
		_marker.queue_free()
	_visual.modulate = Color.WHITE
	effect_triggered.emit(data.id, global_position)
	EventBus.item_effect_triggered.emit(data.id, global_position, data.effect.effect_kind())
	var affected: Array[Node] = data.effect.execute(self)
	effect_resolved.emit(data.id, affected)
	queue_free()


## Urgency reads by blink rate alone (no numbers): 2 Hz fresh -> 10 Hz near zero.
func _update_blink() -> void:
	var urgency := 1.0 - time_remaining() / data.activation_time_seconds
	var hz: float = lerpf(BLINK_MIN_HZ, BLINK_MAX_HZ, urgency)
	var bright := fmod(_elapsed * hz, 1.0) < 0.5
	_visual.modulate = Color.WHITE if bright else Color(0.55, 0.55, 0.55)
	# Near detonation, pulse the size with the blink (Spec 010, G4). Skipped
	# in flight, where _apply_flight owns the scale (squash & stretch).
	if state != State.THROWN and urgency > 0.6:
		var pulse := 1.0 + 0.14 * urgency * absf(sin(_elapsed * hz * PI))
		_visual.scale = Vector2(pulse, pulse)


func _build_graybox_visual() -> void:
	if data.appearance != null:
		var sprite := Sprite2D.new()
		sprite.texture = data.appearance
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_visual = sprite
	else:
		var polygon := Polygon2D.new()
		var points := PackedVector2Array()
		for i in 12:
			points.append(Vector2.from_angle(TAU * i / 12.0) * GRAYBOX_RADIUS_PX)
		polygon.polygon = points
		polygon.color = data.graybox_color
		_visual = polygon
	add_child(_visual)
