## A room exit (Spec 007). Dumb on purpose: the Room tells it to open;
## it announces when the player walks through. No gameplay decisions here.
class_name Door
extends StaticBody2D

signal player_entered(player: Player)

var is_open: bool = false

@onready var _body_visual: Node2D = $Body
@onready var _blocker: CollisionShape2D = $Blocker
@onready var _passage: Area2D = $Passage


func _ready() -> void:
	_passage.body_entered.connect(_on_passage_body_entered)


func open() -> void:
	if is_open:
		return
	is_open = true
	_blocker.set_deferred("disabled", true)
	_passage.set_deferred("monitoring", true)
	# Overbright green modulate = "go" on the graybox door (and future sprite).
	_body_visual.modulate = Color(0.6, 2.0, 0.8)


func _on_passage_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		player_entered.emit(player)
