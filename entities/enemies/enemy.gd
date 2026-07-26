class_name Enemy
extends CharacterBody2D

signal died
signal damage_taken(amount: int)

## Preloaded by path (not the class_name) so CLI/smoke runs don't depend on
## the editor's global class cache having scanned this fresh script.
const IMPACT_BURST: GDScript = preload("res://systems/juice/impact_burst.gd")
const PROJECTILE: PackedScene = preload("res://entities/projectiles/enemy_projectile.tscn")

@export var stats: EnemyStats
## Burst colour on death (Spec 010, G1); tune per archetype in the editor.
@export var death_particle_color: Color = Color(0.95, 0.35, 0.3)

var hits_remaining: int = 0

## Difficulty-scaled stats (Spec 018), computed once at _ready() so the shared
## .tres resources are never mutated (they're cached across instances).
var applied_move_speed: float = 0.0
var applied_shoot_cooldown: float = 0.0
var applied_detection_tiles: float = 0.0
var applied_lunge_recover: float = 0.0

## Knockback decay (Spec 011): shared feel with the player's hit-knockback.
const KNOCKBACK_DECAY: float = 900.0

## Melee attack states (Spec 015): a committed, telegraphed lunge.
enum MeleeState { CHASE, WINDUP, LUNGE, RECOVER }

var _active: bool = true
var _dying: bool = false
var _bob_time: float = 0.0
var _knockback: Vector2 = Vector2.ZERO
var _facing: Vector2 = Vector2.DOWN
var _player: Player
var _shoot_timer: float = 0.0
var _freeze_timer: float = 0.0
var _melee_state: MeleeState = MeleeState.CHASE
var _state_timer: float = 0.0
var _lunge_dir: Vector2 = Vector2.ZERO
var _lunged_hit: bool = false
var _strafe_sign: float = 1.0

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
	_apply_difficulty()
	_body_visual.modulate = _damage_tint()
	_strafe_sign = 1.0 if randf() < 0.5 else -1.0  # per-enemy flank side


## Wizard's multipliers are all 1.0, so the default difficulty is a no-op.
func _apply_difficulty() -> void:
	var difficulty := GameState.difficulty
	applied_move_speed = stats.move_speed * difficulty.enemy_speed_mult
	applied_shoot_cooldown = stats.shoot_cooldown * difficulty.enemy_cooldown_mult
	applied_detection_tiles = stats.detection_radius_tiles * difficulty.enemy_detection_mult
	applied_lunge_recover = stats.lunge_recover * difficulty.enemy_cooldown_mult


func _physics_process(delta: float) -> void:
	if _dying:
		return
	_state_timer = maxf(_state_timer - delta, 0.0)
	_shoot_timer = maxf(_shoot_timer - delta, 0.0)
	var was_frozen := is_frozen()
	_freeze_timer = maxf(_freeze_timer - delta, 0.0)
	if was_frozen and not is_frozen():
		_thaw_flash()
	if not _active:
		velocity = Vector2.ZERO
		_update_animation()
		_update_idle_bob(delta)
		return
	if _player == null:
		# Player may enter the tree after us; resolve once, then keep the cache.
		_player = get_tree().get_first_node_in_group("player") as Player
		if _player == null:
			return
	velocity = Vector2.ZERO
	var to_player := _player.global_position - global_position
	var distance := to_player.length()
	# Vision is blocked by walls (Phase 6A): no line of sight, no chase.
	var visible := distance <= GameState.tiles(applied_detection_tiles) and _can_see_player()
	if stats.is_ranged:
		if visible:
			_ranged_behavior(to_player, distance)
	else:
		# A committed lunge keeps running even if line of sight breaks.
		_melee_update(to_player, distance, visible)
	if velocity != Vector2.ZERO:
		_facing = velocity.normalized()
	# Knockback rides on top of intended movement, then decays (Spec 011).
	velocity += _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
	move_and_slide()
	_update_animation()
	_update_idle_bob(delta)


## Room state machine gates this: inactive during the WAITING telegraph.
## Inactive enemies still take damage — only behavior is paused.
func set_active(value: bool) -> void:
	_active = value


## Shove impulse (Spec 011, Left Hand of Ursula), decays in movement.
func apply_knockback(impulse: Vector2) -> void:
	_knockback = impulse


## Clear line of sight to the player — no wall (layer 1) in between (Phase 6A).
func _can_see_player() -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
			global_position, _player.global_position, 1)
	return space.intersect_ray(query).is_empty()


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
	EventBus.enemy_damaged.emit(self)
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


## Smart chaser (Spec 015): steer in (separation + strafe + wall avoidance),
## then a telegraphed lunge. WINDUP/LUNGE/RECOVER are committed — they run to
## completion even if the player breaks line of sight (dodgeable, not cancelable).
func _melee_update(to_player: Vector2, distance: float, visible: bool) -> void:
	match _melee_state:
		MeleeState.CHASE:
			if visible and not is_frozen():
				_facing = to_player.normalized()
				velocity = _steer_toward(to_player) * applied_move_speed
				if distance <= GameState.tiles(stats.lunge_range_tiles) and _state_timer <= 0.0:
					_enter_windup(to_player)
		MeleeState.WINDUP:
			_facing = _lunge_dir
			if not is_frozen() and _state_timer <= 0.0:
				_enter_lunge()
		MeleeState.LUNGE:
			if not is_frozen():
				velocity = _lunge_dir * stats.lunge_speed
				_lunge_contact()
				if _state_timer <= 0.0:
					_melee_state = MeleeState.RECOVER
					_state_timer = applied_lunge_recover
					_body_visual.scale = Vector2.ONE
		MeleeState.RECOVER:
			if _state_timer <= 0.0:
				_melee_state = MeleeState.CHASE


func _enter_windup(to_player: Vector2) -> void:
	_melee_state = MeleeState.WINDUP
	_state_timer = stats.lunge_windup
	_lunge_dir = to_player.normalized()
	_body_visual.scale = Vector2(1.3, 0.75)  # crouch — telegraph


func _enter_lunge() -> void:
	_melee_state = MeleeState.LUNGE
	_state_timer = stats.lunge_duration
	_lunged_hit = false
	_body_visual.scale = Vector2(0.8, 1.25)  # stretch into the lunge


func _lunge_contact() -> void:
	if _lunged_hit:
		return
	if global_position.distance_to(_player.global_position) <= GameState.tiles(0.8):
		_lunged_hit = true
		_player.take_damage(stats.damage, self)


## Blend: seek the player + push off neighbours + a little flank + wall dodge.
func _steer_toward(to_player: Vector2) -> Vector2:
	var seek := to_player.normalized()
	var sep := _separation() * stats.separation_weight
	var strafe := seek.orthogonal() * _strafe_sign * stats.strafe_weight
	var avoid := _wall_avoidance(seek)
	return (seek + sep + strafe + avoid).normalized()


func _separation() -> Vector2:
	var push := Vector2.ZERO
	var radius := GameState.tiles(stats.separation_radius_tiles)
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
		var body := other as Node2D
		if body == null:
			continue
		var offset := global_position - body.global_position
		var dist := offset.length()
		if dist > 0.1 and dist < radius:
			push += offset.normalized() * (1.0 - dist / radius)
	return push


## If a wall is right ahead, steer toward whichever side is open.
func _wall_avoidance(seek: Vector2) -> Vector2:
	var space := get_world_2d().direct_space_state
	var reach := GameState.tiles(1.0)
	var ahead := PhysicsRayQueryParameters2D.create(global_position, global_position + seek * reach, 1)
	if space.intersect_ray(ahead).is_empty():
		return Vector2.ZERO
	var left := seek.rotated(-PI / 2.0)
	var left_query := PhysicsRayQueryParameters2D.create(global_position, global_position + left * reach, 1)
	var open_left := space.intersect_ray(left_query).is_empty()
	return (left if open_left else -left) * 1.3


## Ranged (kiter): hold a preferred distance and fire on cooldown.
func _ranged_behavior(to_player: Vector2, distance: float) -> void:
	var preferred := GameState.tiles(stats.preferred_distance_tiles)
	var band := GameState.tiles(0.75)
	if not is_frozen():
		if distance > preferred + band:
			velocity = to_player.normalized() * applied_move_speed  # approach
		elif distance < preferred - band:
			velocity = -to_player.normalized() * applied_move_speed  # back off
		# otherwise hold position and shoot
		_facing = to_player.normalized()
	if _shoot_timer <= 0.0 and not is_frozen():
		_shoot(to_player)
		_shoot_timer = applied_shoot_cooldown


func _shoot(to_player: Vector2) -> void:
	var projectile := PROJECTILE.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.launch(to_player.normalized())
	EventBus.enemy_shot.emit()


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


## Subtle standing bob (Spec 010, G5) — while holding still (idle/telegraph),
## not frozen, not dying. Reads as menacing life before combat.
func _update_idle_bob(delta: float) -> void:
	if _body_sprite == null:
		return
	if velocity == Vector2.ZERO and not is_frozen() and not _dying:
		_bob_time += delta
		_body_sprite.position.y = sin(_bob_time * 5.0) * 1.0
	else:
		_bob_time = 0.0
		_body_sprite.position.y = 0.0


## Icy overbright pop as the freeze breaks (Spec 010, G2), settling to normal.
func _thaw_flash() -> void:
	EventBus.freeze_ended.emit()
	modulate = Color(2.0, 2.2, 2.6)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


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
