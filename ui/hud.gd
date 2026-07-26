## HUD (Specs 008 + 009): presentation only. Listens to EventBus, reads
## player health via group lookup, never calls gameplay methods.
## MVP layout (Spec 009): bottom bar — hearts left, drawn item's picture
## right (provisional position; 🔺/⭕ special slots are post-MVP).
## Art swap is editor-only: assign heart_texture below and/or drop textures
## on BarBgTex / SlotFrameTex in hud.tscn; the graybox hides itself.
extends CanvasLayer

const HEART_FULL := Color(0.9, 0.2, 0.3)
const HEART_EMPTY := Color(0.14, 0.1, 0.12)

## Heart sprites from Design (applied to all 5 hearts); graybox squares until set.
@export var heart_filled_texture: Texture2D
@export var heart_empty_texture: Texture2D
## Fallback tint for lost hearts if only the filled texture is assigned.
@export var heart_empty_tint := Color(0.3, 0.3, 0.3, 0.8)

var _player: Player

@onready var _hearts: Array[Node] = $Bar/Hearts.get_children()
@onready var _bar_bg: ColorRect = $Bar/BarBg
@onready var _bar_bg_tex: NinePatchRect = $Bar/BarBgTex
@onready var _slot_bg: ColorRect = $Bar/HeldSlot/SlotBg
@onready var _slot_frame_tex: NinePatchRect = $Bar/HeldSlot/SlotFrameTex
@onready var _held_icon: ColorRect = $Bar/HeldSlot/HeldIcon
@onready var _held_icon_tex: TextureRect = $Bar/HeldSlot/HeldIconTex
@onready var _item_name: Label = $Bar/HeldSlot/ItemName


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.item_drawn.connect(_on_item_drawn)
	EventBus.item_thrown.connect(_on_item_thrown)
	EventBus.item_effect_triggered.connect(_on_item_effect_triggered)
	_apply_art()
	_clear_held()
	_refresh_hearts.call_deferred()


## Any texture assigned in the editor replaces its graybox stand-in.
func _apply_art() -> void:
	_bar_bg_tex.visible = _bar_bg_tex.texture != null
	_bar_bg.visible = not _bar_bg_tex.visible
	_slot_frame_tex.visible = _slot_frame_tex.texture != null
	_slot_bg.visible = not _slot_frame_tex.visible
	for heart in _hearts:
		var tex := heart.get_node("Tex") as TextureRect
		tex.texture = heart_filled_texture
		tex.visible = heart_filled_texture != null


func _refresh_hearts() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	for i in _hearts.size():
		var full := i < _player.health
		var heart := _hearts[i] as ColorRect
		if heart_filled_texture != null:
			heart.color = Color(0, 0, 0, 0)
			var tex := heart.get_node("Tex") as TextureRect
			# Empty hearts sit centered in the bar; full ones float up half a
			# heart, so active lives read as raised above the empty sockets.
			var raise := heart.custom_minimum_size.y * 0.5 if full else 0.0
			tex.offset_top = -raise
			tex.offset_bottom = -raise
			if full:
				tex.texture = heart_filled_texture
				tex.modulate = Color.WHITE
			elif heart_empty_texture != null:
				tex.texture = heart_empty_texture
				tex.modulate = Color.WHITE
			else:
				tex.texture = heart_filled_texture
				tex.modulate = heart_empty_tint
		else:
			heart.color = HEART_FULL if full else HEART_EMPTY


func _clear_held() -> void:
	_held_icon.visible = false
	_held_icon_tex.visible = false
	_item_name.text = ""


func _on_player_damaged(_amount: int, _source: Node) -> void:
	_refresh_hearts()


func _on_item_drawn(item_data: MagicItemResource) -> void:
	var has_art := item_data.appearance != null
	_held_icon_tex.visible = has_art
	_held_icon_tex.texture = item_data.appearance
	_held_icon.visible = not has_art
	_held_icon.color = item_data.graybox_color
	_item_name.text = item_data.display_name


func _on_item_thrown(_item_id: StringName, _position: Vector2, _direction: Vector2) -> void:
	_clear_held()


## Covers the held-until-it-blew case; harmless no-op after a throw.
func _on_item_effect_triggered(_item_id: StringName, _position: Vector2, _kind: StringName) -> void:
	_clear_held()
