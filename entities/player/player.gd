class_name Player
extends CharacterBody2D

signal dash_started
signal dash_ended
signal damage_taken(amount: int, source: Node)
signal attack_pressed
signal special_pressed

enum State { IDLE, MOVE, DASH }

@export var stats: PlayerStats

var facing: Vector2 = Vector2.DOWN
var health: int = 0

var _state: State = State.IDLE
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _freeze_timer: float = 0.0
var _knockback: Vector2 = Vector2.ZERO

@onready var _facing_pivot: Node2D = $FacingPivot
@onready var _facing_marker: Marker2D = $FacingPivot/FacingMarker
# Typed loosely on purpose: any Node2D visual (Polygon2D graybox today,
# AnimatedSprite2D in Phase 4) can be dropped in as "Body" with no code change.
# All feedback goes through `modulate`, which every CanvasItem has.
@onready var _body_visual: Node2D = $Body
# Null when Body is still a graybox polygon; guarded in _update_animation().
@onready var _body_sprite: AnimatedSprite2D = $Body as AnimatedSprite2D
@onready var _bag: Bag = $Bag


func _ready() -> void:
	add_to_group("player")
	# Health persists across room transitions via GameState (-1 = full).
	health = GameState.player_health if GameState.player_health > 0 else stats.max_health


func _physics_process(delta: float) -> void:
	_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)
	var was_frozen := is_frozen()
	_freeze_timer = maxf(_freeze_timer - delta, 0.0)
	if was_frozen and not is_frozen():
		_thaw_flash()
	if _state == State.DASH:
		_tick_dash(delta)
	else:
		_tick_move()
	# Knockback rides on top of intended movement, then decays — so a hit
	# shoves the player even while frozen (movement-locked) or idle.
	velocity += _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, stats.hit_knockback_decay * delta)
	move_and_slide()
	_facing_pivot.rotation = facing.angle()
	_update_animation()
	if Input.is_action_just_pressed("attack"):
		attack_pressed.emit()
		_bag.draw_or_throw(facing)
	if Input.is_action_just_pressed("special"):
		special_pressed.emit()
		_kick()


func is_dashing() -> bool:
	return _state == State.DASH


func is_frozen() -> bool:
	return _freeze_timer > 0.0


## Movement-lock only (team decision 2026-07-25): a frozen player still acts.
func freeze(duration: float) -> void:
	_freeze_timer = duration
	modulate = Color(0.55, 0.8, 1.0)


## World position items are thrown/kicked from (ahead of the player, facing-side).
func throw_origin() -> Vector2:
	return _facing_marker.global_position


func take_damage(amount: int, source: Node) -> void:
	# Dash i-frames block enemy damage only — never the player's own item effects.
	if is_dashing() and source != null and source.is_in_group("enemies"):
		return
	health -= amount
	damage_taken.emit(amount, source)
	EventBus.player_damaged.emit(amount, source)
	_flash_damage()
	# Game feel (Spec 010, G1): shove away from the hit + a beat of hitstop.
	if source is Node2D:
		var away := (global_position - (source as Node2D).global_position).normalized()
		_knockback = away * stats.hit_knockback_speed
	Juice.hitstop(0.05)
	if health <= 0:
		GameState.player_health = -1
		EventBus.player_died.emit()
		get_tree().reload_current_scene.call_deferred()


func _tick_move() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		facing = _snap_to_8(input_dir)
	if is_frozen():
		velocity = Vector2.ZERO
		_state = State.IDLE
		return
	velocity = input_dir * stats.move_speed
	_state = State.MOVE if input_dir != Vector2.ZERO else State.IDLE
	if Input.is_action_just_pressed("dash") and _dash_cooldown_timer <= 0.0:
		_start_dash(input_dir if input_dir != Vector2.ZERO else facing)


func _start_dash(direction: Vector2) -> void:
	_state = State.DASH
	_dash_direction = direction.normalized()
	_dash_timer = stats.dash_duration
	dash_started.emit()


func _tick_dash(delta: float) -> void:
	velocity = _dash_direction * stats.dash_speed
	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_state = State.IDLE
		_dash_cooldown_timer = stats.dash_cooldown
		dash_ended.emit()


## Apprentice Boot: redirect a thrown/landed item 5 tiles further,
## OR (if no item is in reach) 1 hit to enemies near the facing point.
func _kick() -> void:
	var kick_point := throw_origin()
	var kick_range := GameState.tiles(stats.kick_range_tiles)
	for node: Node in get_tree().get_nodes_in_group("magic_items"):
		var item := node as MagicItem
		if item != null and item.is_kickable() \
				and item.global_position.distance_to(kick_point) <= kick_range:
			item.kick(facing)
			return
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.global_position.distance_to(kick_point) <= kick_range:
			enemy.take_damage(stats.kick_damage)


func _snap_to_8(direction: Vector2) -> Vector2:
	return Vector2.from_angle(snappedf(direction.angle(), PI / 4.0))


## Maps the 8-way facing onto the 4 directional animations (horizontal wins
## on diagonals). Walking plays the loop; standing still holds the idle pose.
func _update_animation() -> void:
	if _body_sprite == null:
		return
	var anim: StringName
	if absf(facing.x) > absf(facing.y):
		anim = &"walk_right" if facing.x > 0.0 else &"walk_left"
	else:
		anim = &"walk_front" if facing.y > 0.0 else &"walk_back"
	if velocity != Vector2.ZERO and not is_frozen():
		_body_sprite.play(anim)
	else:
		_body_sprite.animation = anim
		_body_sprite.stop()


func _flash_damage() -> void:
	_body_visual.modulate = Color(1.0, 0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(_body_visual, "modulate", Color.WHITE, 0.25)


## Icy overbright pop as the freeze breaks (Spec 010, G2), settling to normal.
func _thaw_flash() -> void:
	modulate = Color(2.0, 2.2, 2.6)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)
