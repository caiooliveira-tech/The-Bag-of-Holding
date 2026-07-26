## Trauma-based screen shake (Spec 010, G1). Drop this script on a room's
## Camera2D. It listens to EventBus and shakes the view on impact — never on
## freeze (crowd control feels cold, not violent; the zoom punch is G2).
##
## Trauma (0..1) decays every frame; the actual shake is trauma², so small
## traumas barely register and big ones hit hard, and stacked events add up
## and self-clear. Drives `offset` only (no rotation) to keep combat readable.
extends Camera2D

@export var max_offset: Vector2 = Vector2(10.0, 8.0)
@export var decay_per_second: float = 1.6

## Trauma added per event kind.
@export var explosion_trauma: float = 0.5
@export var player_hit_trauma: float = 0.35
@export var enemy_death_trauma: float = 0.2

var _trauma: float = 0.0
var _base_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_offset = offset
	EventBus.item_effect_triggered.connect(_on_item_effect_triggered)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.enemy_died.connect(_on_enemy_died)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		offset = _base_offset
		return
	_trauma = maxf(_trauma - decay_per_second * delta, 0.0)
	var shake := _trauma * _trauma
	offset = _base_offset + Vector2(
		randf_range(-1.0, 1.0) * max_offset.x,
		randf_range(-1.0, 1.0) * max_offset.y,
	) * shake


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _on_item_effect_triggered(_id: StringName, _pos: Vector2, kind: StringName) -> void:
	# Freeze does not shake (G2 gives it a zoom punch instead).
	if kind == &"area_damage":
		add_trauma(explosion_trauma)


func _on_player_damaged(_amount: int, _source: Node) -> void:
	add_trauma(player_hit_trauma)


func _on_enemy_died(_enemy: Node) -> void:
	add_trauma(enemy_death_trauma)
