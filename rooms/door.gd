## A room exit (Spec 007). Dumb on purpose: the Room tells it to open;
## it announces when the player walks through. No gameplay decisions here.
class_name Door
extends StaticBody2D

signal player_entered(player: Player)

## Tile art per room palette (Design template cols 8/9); assign both, or
## leave empty to keep the graybox polygon + green-modulate fallback.
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

var is_open: bool = false

@onready var _body_visual: Node2D = $Body
@onready var _blocker: CollisionShape2D = $Blocker
@onready var _passage: Area2D = $Passage


func _ready() -> void:
	_passage.body_entered.connect(_on_passage_body_entered)
	_apply_texture(closed_texture)


func open() -> void:
	if is_open:
		return
	is_open = true
	_blocker.set_deferred("disabled", true)
	_passage.set_deferred("monitoring", true)
	if open_texture != null:
		_apply_texture(open_texture)
	else:
		# Graybox fallback: overbright green modulate = "go".
		_body_visual.modulate = Color(0.6, 2.0, 0.8)


## Swaps every sprite leaf under Body (the door is two 32 px leaves).
func _apply_texture(texture: Texture2D) -> void:
	if texture == null:
		return
	for child in _body_visual.get_children():
		var sprite := child as Sprite2D
		if sprite != null:
			sprite.texture = texture


func _on_passage_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		player_entered.emit(player)
