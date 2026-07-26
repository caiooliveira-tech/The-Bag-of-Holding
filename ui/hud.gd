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
var _heart_tweens: Array[Tween] = []

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
	_sync_heart_count(_player.max_health())
	if _heart_tweens.is_empty():
		_heart_tweens.resize(_hearts.size())
	for i in _hearts.size():
		var full := i < _player.health
		var heart := _hearts[i] as ColorRect
		if heart_filled_texture != null:
			heart.color = Color(0, 0, 0, 0)
			var tex := heart.get_node("Tex") as TextureRect
			if full:
				tex.texture = heart_filled_texture
				tex.modulate = Color.WHITE
			elif heart_empty_texture != null:
				tex.texture = heart_empty_texture
				tex.modulate = Color.WHITE
			else:
				tex.texture = heart_filled_texture
				tex.modulate = heart_empty_tint
			# Empty hearts sit centered in the bar; full ones float up half a
			# heart, so active lives read as raised above the empty sockets.
			var target := -heart.custom_minimum_size.y * 0.5 if full else 0.0
			_animate_heart(i, tex, target)
		else:
			heart.color = HEART_FULL if full else HEART_EMPTY


## Heart count follows the difficulty's max health (Spec 018): clone the
## scene's first heart as a template (art + Tex child carry over) or trim
## extras. The bar stays presentation-only — it just mirrors player state.
func _sync_heart_count(count: int) -> void:
	if _hearts.size() == count:
		return
	var box := _hearts[0].get_parent()
	while box.get_child_count() < count:
		box.add_child((_hearts[0] as Node).duplicate())
	while box.get_child_count() > count:
		var last := box.get_child(box.get_child_count() - 1)
		box.remove_child(last)
		last.queue_free()
	_hearts = box.get_children()
	for tween in _heart_tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	_heart_tweens.clear()
	_heart_tweens.resize(count)
	for heart in _hearts:
		var tex := heart.get_node("Tex") as TextureRect
		tex.texture = heart_filled_texture
		tex.visible = heart_filled_texture != null


## Tween a heart to its raised (full) or centered (empty) offset, so losing a
## life visibly drops it into the socket and gaining one pops it up.
func _animate_heart(index: int, tex: TextureRect, target: float) -> void:
	if is_equal_approx(tex.offset_top, target):
		return
	var previous := _heart_tweens[index]
	if previous != null and previous.is_valid():
		previous.kill()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(tex, "offset_top", target, 0.22)
	tween.parallel().tween_property(tex, "offset_bottom", target, 0.22)
	_heart_tweens[index] = tween


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
