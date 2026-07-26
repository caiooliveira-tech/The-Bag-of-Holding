## Main menu (Spec 022 redesign). Keyboard-driven: W/S or ↑/↓ to move,
## Enter/Space to select, or press an item's hotkey letter directly. Brick
## backdrop + logo banner + the crow illustration, built on the MenuUI helper.
## Behavior is unchanged from Spec 009/018 — only the look was reworked.
extends Control

const DIFFICULTY_SELECT := "res://ui/menu/difficulty_select.tscn"
const OPTIONS := "res://ui/menu/options_menu.tscn"
const CREDITS := "res://ui/menu/credits.tscn"

# Load Game is hidden until a save system exists (post-MVP). The description
# beside the buttons adapts to the selection, in the intro's tone of voice.
const ITEMS: Array[Dictionary] = [
	{
		"label": "NEW GAME", "hotkey": "N", "keycode": KEY_N,
		"desc": "Outsmart your enemies with the tools you have inside your bottomless bag.\n\n" +
			"Unlock the doors to continue heading to the top and rescue your master.",
	},
	{
		"label": "OPTIONS", "hotkey": "O", "keycode": KEY_O,
		"desc": "Set the screen to your liking and study the controls.\n\n" +
			"A clumsy apprentice needs every advantage he can dig out of the bag.",
	},
	{
		"label": "CREDITS", "hotkey": "C", "keycode": KEY_C,
		"desc": "Meet the clumsy hands and warm hearts that stitched this bottomless bag together.",
	},
	{
		"label": "EXIT GAME", "hotkey": "E", "keycode": KEY_E,
		"desc": "Close the bag and step away.\n\n" +
			"The tower — and your master — will wait for your return.",
	},
]

var _selected: int = 0
var _rows: Array[TextureRect] = []
var _keys: Array[Label] = []
var _desc: Label


func _ready() -> void:
	_build()
	_refresh()
	AudioManager.play_music(&"menu")


func _build() -> void:
	MenuUI.brick(self)

	# The crow + bag illustration anchors the right half of the screen.
	MenuUI.image(self, MenuUI.CROW, Vector2(690, 70), Vector2(560, 560))

	# Logo on its corner parchment, flush to the top-left.
	MenuUI.corner_logo(self)

	var first_button_y := 288.0
	for i in ITEMS.size():
		var row := MenuUI.button_row(self, ITEMS[i]["label"], Vector2(80, first_button_y + i * 58))
		var key_label := MenuUI.label("[%s]" % ITEMS[i]["hotkey"], MenuUI.FONT_REG, 14, MenuUI.LIGHT_MUTED)
		key_label.position = Vector2(258, 13)
		row.add_child(key_label)
		_rows.append(row)
		_keys.append(key_label)

	# Description beside the buttons, its top aligned to the first button.
	_desc = MenuUI.label("", MenuUI.FONT_REG, 16, MenuUI.LIGHT_MUTED)
	_desc.position = Vector2(470, first_button_y + 4.0)
	_desc.size.x = 210.0
	_desc.custom_minimum_size = Vector2(210, 0)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_desc)

	MenuUI.label_at(self, "[W/S] / [UP/DOWN] NAVIGATE MENU", MenuUI.FONT_REG, 12,
			MenuUI.LIGHT_MUTED, Vector2(80, 688))
	var sel := MenuUI.label("[SPACE/ENTER] SELECT OPTION", MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED)
	sel.position = Vector2(980, 688)
	add_child(sel)


func _refresh() -> void:
	for i in _rows.size():
		var active := i == _selected
		MenuUI.select_button(_rows[i], active)
		_keys[i].position.x = 298.0 if active else 258.0
	_desc.text = ITEMS[_selected]["desc"]


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
	AudioManager.play_sfx(&"button_change")


func _activate(index: int) -> void:
	AudioManager.play_sfx(&"button_clicked")
	match ITEMS[index]["label"]:
		"NEW GAME":
			# Difficulty select owns run setup (Spec 018): it sets the
			# difficulty, resets the run, and starts room_01.
			get_tree().change_scene_to_file(DIFFICULTY_SELECT)
		"OPTIONS":
			get_tree().change_scene_to_file(OPTIONS)
		"CREDITS":
			get_tree().change_scene_to_file(CREDITS)
		"EXIT GAME":
			get_tree().quit()
