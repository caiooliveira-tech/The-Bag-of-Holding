## Main menu (new scene). Keyboard-driven: W/S or ↑/↓ to move, Enter/Space to
## select, or press an item's hotkey letter directly. Built in code so the
## layout stays in one place and the wooden button art drives the look.
extends Control

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")
const BTN_ACTIVE: Texture2D = preload("res://assets/ui/btn_active.png")
const BTN_INACTIVE: Texture2D = preload("res://assets/ui/btn_inactive.png")

const ROOM_01 := "res://rooms/room_01.tscn"
const OPTIONS := "res://ui/menu/options_menu.tscn"
const CREDITS := "res://ui/menu/credits.tscn"

const BG := Color(0.09, 0.08, 0.11)
const TEXT := Color(0.93, 0.92, 0.95)
const MUTED := Color(0.62, 0.6, 0.66)

const ITEMS: Array[Dictionary] = [
	{"label": "NEW GAME", "hotkey": "N", "keycode": KEY_N},
	{"label": "LOAD GAME", "hotkey": "L", "keycode": KEY_L},
	{"label": "OPTIONS", "hotkey": "O", "keycode": KEY_O},
	{"label": "CREDITS", "hotkey": "C", "keycode": KEY_C},
	{"label": "EXIT GAME", "hotkey": "E", "keycode": KEY_E},
]

var _selected: int = 0
var _rows: Array[TextureRect] = []


func _ready() -> void:
	_build()
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _label("THE BAG OF NO BOTTOM", FONT_BOLD, 30, TEXT)
	title.position = Vector2(80, 52)
	add_child(title)

	for i in ITEMS.size():
		var row := TextureRect.new()
		row.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		row.stretch_mode = TextureRect.STRETCH_SCALE
		row.position = Vector2(80, 132 + i * 52)
		row.custom_minimum_size = Vector2(360, 44)
		add_child(row)
		var name_label := _label(ITEMS[i]["label"], FONT_BOLD, 16, TEXT)
		name_label.position = Vector2(24, 12)
		row.add_child(name_label)
		var key_label := _label("[%s]" % ITEMS[i]["hotkey"], FONT_REG, 14, MUTED)
		key_label.position = Vector2(250, 13)
		row.add_child(key_label)
		_rows.append(row)

	var desc := _label(
		"Outsmart your enemies with the tools you have inside your bottomless bag.\n\n" +
		"Unlock the doors to continue heading to the top and rescue your master.",
		FONT_REG, 16, MUTED)
	desc.position = Vector2(470, 140)
	desc.custom_minimum_size = Vector2(260, 0)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(desc)

	var nav := _label("[W/S] / [UP/DOWN] NAVIGATE MENU", FONT_REG, 12, MUTED)
	nav.position = Vector2(80, 688)
	add_child(nav)
	var sel := _label("[SPACE/ENTER] SELECT OPTION", FONT_REG, 12, MUTED)
	sel.position = Vector2(980, 688)
	add_child(sel)


func _refresh() -> void:
	for i in _rows.size():
		var active := i == _selected
		_rows[i].texture = BTN_ACTIVE if active else BTN_INACTIVE
		_rows[i].custom_minimum_size.x = 360.0 if active else 320.0
		_rows[i].size.x = _rows[i].custom_minimum_size.x


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := (event as InputEventKey).keycode
		match key:
			KEY_S, KEY_DOWN:
				_move(1)
			KEY_W, KEY_UP:
				_move(-1)
			KEY_ENTER, KEY_SPACE, KEY_KP_ENTER:
				_activate(_selected)
			_:
				for i in ITEMS.size():
					if key == ITEMS[i]["keycode"]:
						_selected = i
						_refresh()
						_activate(i)
						return


func _move(delta: int) -> void:
	_selected = wrapi(_selected + delta, 0, ITEMS.size())
	_refresh()


func _activate(index: int) -> void:
	match ITEMS[index]["label"]:
		"NEW GAME":
			GameState.reset_run()
			get_tree().change_scene_to_file(ROOM_01)
		"LOAD GAME":
			pass  # no save system yet (post-MVP)
		"OPTIONS":
			get_tree().change_scene_to_file(OPTIONS)
		"CREDITS":
			get_tree().change_scene_to_file(CREDITS)
		"EXIT GAME":
			get_tree().quit()


func _label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label
