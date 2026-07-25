## HUD (Spec 008): presentation only. Listens to EventBus, reads player
## health via group lookup, never calls gameplay methods.
extends CanvasLayer

var _player: Player

@onready var _hearts: Array[Node] = $Hearts.get_children()
@onready var _swatch: ColorRect = $HeldSlot/Swatch
@onready var _item_name: Label = $HeldSlot/ItemName


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.item_drawn.connect(_on_item_drawn)
	EventBus.item_thrown.connect(_on_item_thrown)
	EventBus.item_effect_triggered.connect(_on_item_effect_triggered)
	_clear_held()
	_refresh_hearts.call_deferred()


func _refresh_hearts() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	for i in _hearts.size():
		var full := i < _player.health
		(_hearts[i] as CanvasItem).modulate = Color.WHITE if full else Color(1, 1, 1, 0.15)


func _clear_held() -> void:
	_swatch.visible = false
	_item_name.text = ""


func _on_player_damaged(_amount: int, _source: Node) -> void:
	_refresh_hearts()


func _on_item_drawn(item_data: MagicItemResource) -> void:
	_swatch.visible = true
	_swatch.color = item_data.graybox_color
	_item_name.text = item_data.display_name


func _on_item_thrown(_item_id: StringName, _position: Vector2, _direction: Vector2) -> void:
	_clear_held()


## Covers the held-until-it-blew case; harmless no-op after a throw.
func _on_item_effect_triggered(_item_id: StringName, _position: Vector2) -> void:
	_clear_held()
