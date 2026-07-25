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

var data: MagicItemResource
var state: State = State.HELD

var _elapsed: float = 0.0
var _triggered: bool = false
# Sprite2D when the resource has an appearance texture, Polygon2D graybox
# otherwise — the blink only needs `modulate`, so CanvasItem covers both.
var _visual: CanvasItem


func setup(item_data: MagicItemResource) -> void:
	data = item_data


func _ready() -> void:
	add_to_group("magic_items")
	_build_graybox_visual()
	countdown_started.emit()


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
	_fly(direction, GameState.tiles(2.0))


## Apprentice Boot redirect: +5 tiles, countdown untouched.
func kick(direction: Vector2) -> void:
	if not is_kickable():
		return
	state = State.THROWN
	_fly(direction, GameState.tiles(5.0))
	item_kicked.emit(data.id, global_position)


func _fly(direction: Vector2, distance: float) -> void:
	var dir := direction.normalized()
	var target := global_position + dir * distance
	# Stop short of walls so items never land inside geometry.
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target, 1)
	var hit := space.intersect_ray(query)
	if not hit.is_empty():
		target = (hit.position as Vector2) - dir * GRAYBOX_RADIUS_PX
	var tween := create_tween()
	tween.tween_property(self, "global_position", target, FLIGHT_TIME)
	tween.tween_callback(_on_flight_finished)


func _on_flight_finished() -> void:
	if _triggered:
		return
	state = State.LANDED
	item_landed.emit(data.id, global_position)


func _trigger() -> void:
	_triggered = true
	_visual.modulate = Color.WHITE
	effect_triggered.emit(data.id, global_position)
	EventBus.item_effect_triggered.emit(data.id, global_position)
	var affected: Array[Node] = data.effect.execute(self)
	effect_resolved.emit(data.id, affected)
	queue_free()


## Urgency reads by blink rate alone (no numbers): 2 Hz fresh -> 10 Hz near zero.
func _update_blink() -> void:
	var urgency := 1.0 - time_remaining() / data.activation_time_seconds
	var hz: float = lerpf(BLINK_MIN_HZ, BLINK_MAX_HZ, urgency)
	var bright := fmod(_elapsed * hz, 1.0) < 0.5
	_visual.modulate = Color.WHITE if bright else Color(0.55, 0.55, 0.55)


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
