## The Bag of Holding (Spec 002): owns the pool, the random draw, and the
## held item. Knows nothing about the Player — callers pass direction in.
class_name Bag
extends Node2D

signal item_drawn(item_id: StringName)
signal item_thrown(item_id: StringName, position: Vector2, direction: Vector2)
signal item_landed(item_id: StringName, position: Vector2)
signal item_kicked(item_id: StringName, new_position: Vector2)
signal item_effect_triggered(item_id: StringName)

const MAGIC_ITEM_SCENE: PackedScene = preload("res://systems/magic_items/magic_item.tscn")

@export var pool: ItemPoolResource

var _held_item: MagicItem

@onready var _attach_point: Marker2D = $AttachPoint


func has_held_item() -> bool:
	return _held_item != null and is_instance_valid(_held_item)


## Single Attack input: draw when empty-handed, throw otherwise.
func draw_or_throw(direction: Vector2) -> void:
	if has_held_item():
		_throw_held(direction)
	else:
		_draw_item()


func _draw_item() -> void:
	# The run's growing pool (Spec 017) when a run is active; the static
	# .tres otherwise (dev scene runs, smoke-test injected pools).
	var source: Array[MagicItemResource] = GameState.run_pool \
			if not GameState.run_pool.is_empty() else pool.items
	var item_data: MagicItemResource = source.pick_random()
	var item := MAGIC_ITEM_SCENE.instantiate() as MagicItem
	item.setup(item_data)
	_attach_point.add_child(item)
	_held_item = item
	item.item_landed.connect(_on_item_landed)
	item.item_kicked.connect(_on_item_kicked)
	item.effect_triggered.connect(_on_item_effect_triggered)
	item_drawn.emit(item_data.id)
	EventBus.item_drawn.emit(item_data)


func _throw_held(direction: Vector2) -> void:
	var item := _held_item
	_held_item = null
	item.throw(direction)
	item_thrown.emit(item.data.id, item.global_position, direction)
	EventBus.item_thrown.emit(item.data.id, item.global_position, direction)


func _on_item_landed(item_id: StringName, position: Vector2) -> void:
	item_landed.emit(item_id, position)


func _on_item_kicked(item_id: StringName, new_position: Vector2) -> void:
	item_kicked.emit(item_id, new_position)


func _on_item_effect_triggered(item_id: StringName, _position: Vector2) -> void:
	item_effect_triggered.emit(item_id)
