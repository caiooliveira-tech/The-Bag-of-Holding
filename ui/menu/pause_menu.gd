## Pause menu (autoload "Pause"). ESC during gameplay pauses and shows a
## wooden-button menu in the main-menu style; ESC again resumes. Works while
## the tree is paused (process_mode ALWAYS). Ignored in menus (no player).
extends CanvasLayer

const MAIN_MENU := "res://ui/menu/main_menu.tscn"
const OPTIONS := "res://ui/menu/options_menu.tscn"

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
	dim.color = Color(0.05, 0.04, 0.07, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	# Logo on its corner parchment, flush to the top-left — matches the menu.
	MenuUI.corner_logo(_root)
	MenuUI.label_at(_root, "PAUSED", MenuUI.FONT_BOLD, 22, MenuUI.LIGHT, Vector2(84, 250))

	for i in ITEMS.size():
		var row := MenuUI.button_row(_root, ITEMS[i]["label"], Vector2(80, 296 + i * 58))
		_rows.append(row)

	MenuUI.label_at(_root, "[ESC] RESUME     [W/S] NAVIGATE     [SPACE/ENTER] SELECT",
			MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED, Vector2(80, 688))


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
		MenuUI.select_button(_rows[i], i == _selected)


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


