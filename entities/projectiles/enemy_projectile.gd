## Enemy projectile (Spec 014). Flies straight, damages the player on contact,
## and is stopped by walls (collision mask = walls + player). In group
## "projectiles" so the player's dash/i-frames treat it as enemy damage.
extends Area2D

@export var speed: float = 220.0
@export var damage: int = 1
@export var lifetime: float = 3.0

var _direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func launch(direction: Vector2) -> void:
	_direction = direction.normalized()
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		player.take_damage(damage, self)
	# Player hit or wall — either way the shot is spent.
	queue_free()
