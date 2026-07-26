## A room exit (Spec 007). Dumb on purpose: the Room tells it to open;
## it announces when the player walks through. No gameplay decisions here.
class_name Door
extends StaticBody2D

signal player_entered(player: Player)

const IMPACT_BURST: GDScript = preload("res://systems/juice/impact_burst.gd")

## Tile art per room palette (Design template cols 8/9); assign both, or
## leave empty to keep the graybox polygon + green-modulate fallback.
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

var is_open: bool = false
## The item this door offers once open (Spec 017); null = plain door.
var offered_item: MagicItemResource

var _offer_sprite: Node2D

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
	EventBus.door_opened.emit()
	_blocker.set_deferred("disabled", true)
	_passage.set_deferred("monitoring", true)
	if open_texture != null:
		_apply_texture(open_texture)
	else:
		# Graybox fallback: overbright green modulate = "go".
		_body_visual.modulate = Color(0.6, 2.0, 0.8)
	# Dust puff on open (Spec 010, G5).
	var dust := IMPACT_BURST.new() as CPUParticles2D
	add_child(dust)
	dust.burst(Color(0.75, 0.7, 0.6), 10)


## Assigns and displays this door's item offer (Spec 017). The Room decides
## which item; the door only shows it. `top_level` keeps the icon upright on
## the ±90°-rotated side doors.
func set_offer(item_data: MagicItemResource) -> void:
	offered_item = item_data
	if _offer_sprite != null:
		_offer_sprite.queue_free()
	var holder := Node2D.new()
	holder.top_level = true
	add_child(holder)
	# Float the icon INTO the room, not outside it: the door's local +Y axis
	# points room-inward on all three doors (side doors are ±90°-rotated).
	holder.global_position = global_position + global_transform.y.normalized() * 34.0
	if item_data.appearance != null:
		var sprite := Sprite2D.new()
		sprite.texture = item_data.appearance
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		holder.add_child(sprite)
	else:
		# Graybox fallback, same rule as the HUD.
		var swatch := ColorRect.new()
		swatch.color = item_data.graybox_color
		swatch.size = Vector2(20, 20)
		swatch.position = Vector2(-10, -10)
		holder.add_child(swatch)
	_offer_sprite = holder
	# Gentle bob so the offer reads as pickable (G5 idiom).
	var bob := holder.create_tween().set_loops()
	bob.tween_property(holder, "position:y", holder.position.y - 4.0, 0.4) \
			.set_trans(Tween.TRANS_SINE)
	bob.tween_property(holder, "position:y", holder.position.y, 0.4) \
			.set_trans(Tween.TRANS_SINE)


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
