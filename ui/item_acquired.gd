## "New item acquired" screen (autoload "ItemAcquired", Spec 022/017). When a
## door pickup adds an item to the run pool, Room calls show_and_continue():
## the game pauses, a scroll announces the item by name (with its icon), and the
## next room only loads once the player presses a button. Uses the MenuUI tokens.
extends CanvasLayer

## The bag's proper name, echoed in the announcement copy.
const BAG_NAME := "The Bag of Holding"
## Safety auto-advance if the player never presses anything.
const AUTO_ADVANCE_SECONDS := 6.0

var _root: Control
var _scroll: Control
var _name_label: Label
var _sub_label: Label
var _icon: TextureRect
var _next_path: String = ""
var _active: bool = false


func _ready() -> void:
	layer = 18  # above the Level Title (15), below the Pause menu (20)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.66)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	# Scroll centered on screen; children positioned relative to it.
	var scroll_size := Vector2(470, 470)
	_scroll = Control.new()
	_scroll.size = scroll_size
	_scroll.position = (MenuUI.SCREEN - scroll_size) * 0.5
	_scroll.pivot_offset = scroll_size * 0.5
	_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_scroll)

	var scroll_tex := TextureRect.new()
	scroll_tex.texture = MenuUI.SCROLL
	scroll_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scroll_tex.stretch_mode = TextureRect.STRETCH_SCALE
	scroll_tex.size = scroll_size
	scroll_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.add_child(scroll_tex)

	# Item name (bold, wraps for long names like "The Right Hand of Ursula").
	_name_label = _centered("", MenuUI.FONT_BOLD, 26, MenuUI.INK, 90.0, 70.0, scroll_size.x)
	_sub_label = _centered("was added to\n%s." % BAG_NAME, MenuUI.FONT_REG, 18,
			MenuUI.INK_MUTED, 168.0, 60.0, scroll_size.x)

	# The bag illustration (static) — the announcement is about the bag, per the
	# mock; the item is named in the copy above.
	_icon = TextureRect.new()
	_icon.texture = MenuUI.BAG
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size = Vector2(210, 150)
	_icon.position = Vector2((scroll_size.x - 210.0) * 0.5, 250.0)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.add_child(_icon)

	var hint := _centered("PRESS ANY BUTTON TO CONTINUE", MenuUI.FONT_REG, 14,
			MenuUI.INK_MUTED, 392.0, 24.0, scroll_size.x)
	hint.modulate.a = 0.85


## A horizontally-centered, word-wrapping label inside the scroll's local space.
func _centered(text: String, font: FontFile, size: int, color: Color,
		y: float, height: float, width: float) -> Label:
	var pad := 70.0  # keep clear of the scroll's torn/curled edges
	var label := MenuUI.label(text, font, size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = Vector2(pad, y)
	label.size = Vector2(width - pad * 2.0, height)
	_scroll.add_child(label)
	return label


## Called directly by Room on a door pickup: announce `item_data`, then load
## `next_path` once the player advances. Pauses the game while shown.
func show_and_continue(item_data: MagicItemResource, next_path: String) -> void:
	if _active:
		return
	_active = true
	_next_path = next_path
	_name_label.text = item_data.display_name
	get_tree().paused = true
	_root.visible = true
	_scroll.scale = Vector2(0.8, 0.8)
	_scroll.modulate.a = 0.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_scroll, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_scroll, "modulate:a", 1.0, 0.25)
	# Safety net so a stuck controller never traps the player on this screen.
	get_tree().create_timer(AUTO_ADVANCE_SECONDS).timeout.connect(_continue)


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	var pressed_key: bool = event is InputEventKey and event.pressed and not event.echo
	var pressed_pad: bool = event is InputEventJoypadButton and event.pressed
	var pressed_click: bool = event is InputEventMouseButton and event.pressed
	if pressed_key or pressed_pad or pressed_click:
		get_viewport().set_input_as_handled()
		_continue()


func _continue() -> void:
	if not _active:
		return
	_active = false
	_root.visible = false
	get_tree().paused = false
	if not _next_path.is_empty():
		get_tree().change_scene_to_file(_next_path)
		_next_path = ""
