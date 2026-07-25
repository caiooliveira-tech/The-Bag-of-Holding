## HUD (Spec 008): presentation only. Listens to EventBus, reads player
## health and the bag pool via group lookup, never calls gameplay methods.
## Layout per Flavio's wireframe: bottom bar — hearts left, drawn item's
## picture center, bag pool items right.
extends CanvasLayer

const HEART_FULL := Color(0.9, 0.2, 0.3)
const HEART_EMPTY := Color(0.14, 0.1, 0.12)
const POOL_SLOT_BG := Color(0.09, 0.08, 0.1)

var _player: Player

@onready var _hearts: Array[Node] = $Bar/Hearts.get_children()
@onready var _held_icon: ColorRect = $Bar/HeldSlot/HeldIcon
@onready var _held_icon_tex: TextureRect = $Bar/HeldSlot/HeldIconTex
@onready var _item_name: Label = $Bar/HeldSlot/ItemName
@onready var _pool_box: HBoxContainer = $Bar/PoolBox


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.item_drawn.connect(_on_item_drawn)
	EventBus.item_thrown.connect(_on_item_thrown)
	EventBus.item_effect_triggered.connect(_on_item_effect_triggered)
	_clear_held()
	_refresh_hearts.call_deferred()
	_build_pool_slots.call_deferred()


func _refresh_hearts() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	for i in _hearts.size():
		(_hearts[i] as ColorRect).color = HEART_FULL if i < _player.health else HEART_EMPTY


## One square per item in the Bag's pool (bottom-right). Rendering from the
## pool resource means new items appear here with zero HUD changes.
func _build_pool_slots() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	var bag := _player.get_node_or_null("Bag") as Bag
	if bag == null or bag.pool == null:
		return
	for item_data in bag.pool.items:
		var slot := ColorRect.new()
		slot.custom_minimum_size = Vector2(44, 44)
		slot.color = POOL_SLOT_BG
		var icon := _make_icon(item_data, 32.0)
		icon.position = Vector2(6, 6)
		slot.add_child(icon)
		_pool_box.add_child(slot)


## Item picture: appearance texture once art lands; graybox color until then.
func _make_icon(item_data: MagicItemResource, icon_size: float) -> Control:
	if item_data.appearance != null:
		var tex := TextureRect.new()
		tex.texture = item_data.appearance
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.size = Vector2(icon_size, icon_size)
		return tex
	var rect := ColorRect.new()
	rect.color = item_data.graybox_color
	rect.size = Vector2(icon_size, icon_size)
	return rect


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
func _on_item_effect_triggered(_item_id: StringName, _position: Vector2) -> void:
	_clear_held()
