class_name Enemy
extends CharacterBody2D

signal died
signal damage_taken(amount: int)

## Preloaded by path (not the class_name) so CLI/smoke runs don't depend on
## the editor's global class cache having scanned this fresh script.
const IMPACT_BURST: GDScript = preload("res://systems/juice/impact_burst.gd")

@export var stats: EnemyStats
## Burst colour on death (Spec 010, G1); tune per archetype in the editor.
@export var death_particle_color: Color = Color(0.95, 0.35, 0.3)

var hits_remaining: int = 0

var _active: bool = true
var _dying: bool = false
var _facing: Vector2 = Vector2.DOWN
var _player: Player
var _attack_timer: float = 0.0
var _freeze_timer: float = 0.0

@onready var _collision: CollisionShape2D = $CollisionShape2D

# Typed loosely on purpose: any Node2D visual (Polygon2D graybox today,
# AnimatedSprite2D in Phase 4) can be dropped in as "Body" with no code change.
# All feedback goes through `modulate`, which every CanvasItem has.
@onready var _body_visual: Node2D = $Body
# Null when Body is still a graybox polygon; guarded in _update_animation().
@onready var _body_sprite: AnimatedSprite2D = $Body as AnimatedSprite2D


func _ready() -> void:
	add_to_group("enemies")
	hits_remaining = stats.max_hits
	_body_visual.modulate = _damage_tint()


func _physics_process(delta: float) -> void:
	if _dying:
		return
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	var was_frozen := is_frozen()
	_freeze_timer = maxf(_freeze_timer - delta, 0.0)
	if was_frozen and not is_frozen():
		modulate = Color.WHITE
	if not _active:
		velocity = Vector2.ZERO
		_update_animation()
		return
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
	if velocity != Vector2.ZERO:
		_facing = velocity.normalized()
	move_and_slide()
	_update_animation()


## Room state machine gates this: inactive during the WAITING telegraph.
## Inactive enemies still take damage — only behavior is paused.
func set_active(value: bool) -> void:
	_active = value


func is_frozen() -> bool:
	return _freeze_timer > 0.0


## Movement-lock only (team decision 2026-07-25): a frozen enemy still attacks.
func freeze(duration: float) -> void:
	_freeze_timer = duration
	modulate = Color(0.55, 0.8, 1.0)


func take_damage(amount: int) -> void:
	if _dying:
		return
	hits_remaining -= amount
	damage_taken.emit(amount)
	if hits_remaining <= 0:
		_die()
		return
	_flash_damage()


## Death pop (Spec 010, G1): announce the death now (so the room's clear
## logic runs on time), then play a brief flash/scale/particle burst before
## freeing. The enemy is inert during the pop — no behaviour, no collision.
func _die() -> void:
	_dying = true
	died.emit()
	EventBus.enemy_died.emit(self)
	_collision.set_deferred("disabled", true)
	_spawn_burst()
	Juice.hitstop(0.03)
	_body_visual.modulate = Color(3.0, 3.0, 3.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_body_visual, "scale", Vector2(1.3, 1.3), 0.09)
	tween.tween_property(_body_visual, "modulate:a", 0.0, 0.11)
	tween.chain().tween_callback(queue_free)


func _spawn_burst() -> void:
	var burst := IMPACT_BURST.new() as CPUParticles2D
	get_tree().current_scene.add_child(burst)
	burst.global_position = global_position
	burst.burst(death_particle_color)


func _attack() -> void:
	_attack_timer = stats.attack_cooldown
	_facing = (_player.global_position - global_position).normalized()
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


## Same mapping as the player: 4 directional walk animations, horizontal
## wins on diagonals; standing (or frozen/inactive) holds the idle pose.
func _update_animation() -> void:
	if _body_sprite == null:
		return
	var anim: StringName
	if absf(_facing.x) > absf(_facing.y):
		anim = &"walk_right" if _facing.x > 0.0 else &"walk_left"
	else:
		anim = &"walk_front" if _facing.y > 0.0 else &"walk_back"
	if velocity != Vector2.ZERO:
		_body_sprite.play(anim)
	else:
		_body_sprite.animation = anim
		_body_sprite.stop()
