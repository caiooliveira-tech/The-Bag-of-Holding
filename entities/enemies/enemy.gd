class_name Enemy
extends CharacterBody2D

signal died
signal damage_taken(amount: int)

@export var stats: EnemyStats

var hits_remaining: int = 0

var _player: Player
var _attack_timer: float = 0.0
var _freeze_timer: float = 0.0

# Typed loosely on purpose: any Node2D visual (Polygon2D graybox today,
# AnimatedSprite2D in Phase 4) can be dropped in as "Body" with no code change.
# All feedback goes through `modulate`, which every CanvasItem has.
@onready var _body_visual: Node2D = $Body


func _ready() -> void:
	add_to_group("enemies")
	hits_remaining = stats.max_hits
	_body_visual.modulate = _damage_tint()


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


## Darker/more saturated as the enemy nears its last hit (art-direction.md).
## A `modulate` multiplier, so it works the same on graybox and future sprites.
func _damage_tint() -> Color:
	var damage_fraction := 1.0 - float(hits_remaining) / float(stats.max_hits)
	return Color.WHITE.lerp(Color(0.55, 0.08, 0.08), damage_fraction)


func _flash_damage() -> void:
	# Overbright modulate reads as a white-hot flash even on saturated colors.
	_body_visual.modulate = Color(3.0, 3.0, 3.0)
	var tween := create_tween()
	tween.tween_property(_body_visual, "modulate", _damage_tint(), 0.2)
