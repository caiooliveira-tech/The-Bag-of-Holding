class_name Enemy
extends CharacterBody2D

signal died
signal damage_taken(amount: int)

@export var stats: EnemyStats

var hits_remaining: int = 0

var _player: Player
var _attack_timer: float = 0.0
var _freeze_timer: float = 0.0

@onready var _body_visual: Polygon2D = $Body


func _ready() -> void:
	add_to_group("enemies")
	hits_remaining = stats.max_hits
	_body_visual.color = _base_color()


func _physics_process(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	var was_frozen := is_frozen()
	_freeze_timer = maxf(_freeze_timer - delta, 0.0)
	if was_frozen and not is_frozen():
		modulate = Color.WHITE
	if _player == null:
		# Player may enter the tree after us; resolve once, then keep the cache.
		_player = get_tree().get_first_node_in_group("player") as Player
		if _player == null:
			return
	velocity = Vector2.ZERO
	var to_player := _player.global_position - global_position
	var distance := to_player.length()
	if distance <= GameState.tiles(stats.detection_radius_tiles):
		if distance > GameState.tiles(stats.attack_range_tiles):
			if not is_frozen():
				velocity = to_player.normalized() * stats.move_speed
		elif _attack_timer <= 0.0:
			_attack()
	move_and_slide()


func is_frozen() -> bool:
	return _freeze_timer > 0.0


## Movement-lock only (team decision 2026-07-25): a frozen enemy still attacks.
func freeze(duration: float) -> void:
	_freeze_timer = duration
	modulate = Color(0.55, 0.8, 1.0)


func take_damage(amount: int) -> void:
	hits_remaining -= amount
	damage_taken.emit(amount)
	if hits_remaining <= 0:
		died.emit()
		EventBus.enemy_died.emit(self)
		queue_free()
		return
	_flash_damage()


func _attack() -> void:
	_attack_timer = stats.attack_cooldown
	_player.take_damage(stats.damage, self)
	# Telegraph: quick scale punch toward readability without extra sprites.
	_body_visual.scale = Vector2(1.3, 1.3)
	var tween := create_tween()
	tween.tween_property(_body_visual, "scale", Vector2.ONE, 0.15)


## Darker/more saturated red as the enemy nears its last hit (art-direction.md).
func _base_color() -> Color:
	var damage_fraction := 1.0 - float(hits_remaining) / float(stats.max_hits)
	return Color(0.85, 0.3, 0.3).lerp(Color(0.45, 0.03, 0.03), damage_fraction)


func _flash_damage() -> void:
	_body_visual.color = Color.WHITE
	var tween := create_tween()
	tween.tween_property(_body_visual, "color", _base_color(), 0.2)
