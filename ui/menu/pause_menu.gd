## Pause menu (autoload "Pause"). ESC during gameplay pauses and shows a
## wooden-button menu in the main-menu style; ESC again resumes. Works while
## the tree is paused (process_mode ALWAYS). Ignored in menus (no player).
extends CanvasLayer

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")
const BTN_ACTIVE: Texture2D = preload("res://assets/ui/btn_active.png")
const BTN_INACTIVE: Texture2D = preload("res://assets/ui/btn_inactive.png")

const MAIN_MENU := "res://ui/menu/main_menu.tscn"
const OPTIONS := "res://ui/menu/options_menu.tscn"

const TEXT := Color(0.93, 0.92, 0.95)
const MUTED := Color(0.62, 0.6, 0.66)

const ITEMS: Array[Dictionary] = [
	{"label": "RESTART LEVEL", "action": &"restart"},
	{"label": "OPTIONS", "action": &"options"},
	{"label": "QUIT TO MAIN MENU", "action": &"menu"},
	{"label": "EXIT GAME", "action": &"exit"},
]

var _open: bool = false
var _selected: int = 0
var _rows: Array[TextureRect] = []
var _root: Control


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.04, 0.07, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	var title := _label("THE BAG OF NO BOTTOM", FONT_BOLD, 30, TEXT)
	title.position = Vector2(80, 52)
	_root.add_child(title)

	for i in ITEMS.size():
		var row := TextureRect.new()
		row.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		row.stretch_mode = TextureRect.STRETCH_SCALE
		row.position = Vector2(80, 132 + i * 52)
		row.custom_minimum_size = Vector2(360, 44)
		_root.add_child(row)
		var name_label := _label(ITEMS[i]["label"], FONT_BOLD, 16, TEXT)
		name_label.position = Vector2(24, 12)
		row.add_child(name_label)
		_rows.append(row)

	var hint := _label("[ESC] RESUME     [W/S] NAVIGATE     [SPACE/ENTER] SELECT", FONT_REG, 12, MUTED)
	hint.position = Vector2(80, 688)
	_root.add_child(hint)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key := (event as InputEventKey).keycode
	if key == KEY_ESCAPE:
		if _open:
			_resume()
		elif _in_gameplay():
			_pause()
		return
	if not _open:
		return
	match key:
		KEY_S, KEY_DOWN:
			_move(1)
		KEY_W, KEY_UP:
			_move(-1)
		KEY_ENTER, KEY_SPACE, KEY_KP_ENTER:
			_activate(_selected)


func _in_gameplay() -> bool:
	return get_tree().get_first_node_in_group("player") != null


func _pause() -> void:
	_open = true
	_selected = 0
	_refresh()
	_root.visible = true
	get_tree().paused = true


func _resume() -> void:
	_open = false
	_root.visible = false
	get_tree().paused = false


func _move(delta: int) -> void:
	_selected = wrapi(_selected + delta, 0, ITEMS.size())
	_refresh()
	AudioManager.play_sfx(&"button_change")


func _refresh() -> void:
	for i in _rows.size():
		var active := i == _selected
		_rows[i].texture = BTN_ACTIVE if active else BTN_INACTIVE
		_rows[i].custom_minimum_size.x = 360.0 if active else 320.0
		_rows[i].size.x = _rows[i].custom_minimum_size.x


func _activate(index: int) -> void:
	AudioManager.play_sfx(&"button_clicked")
	var action: StringName = ITEMS[index]["action"]
	_resume()
	match action:
		&"restart":
			get_tree().reload_current_scene()
		&"options":
			get_tree().change_scene_to_file(OPTIONS)
		&"menu":
			GameState.reset_run()
			get_tree().change_scene_to_file(MAIN_MENU)
		&"exit":
			get_tree().quit()


func _label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label
