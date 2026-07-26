## Difficulty select (Spec 018), shown after New Game. Same code-driven,
## wooden-button pattern as the main menu: W/S or arrows to move, Enter/Space
## to select, or a level's number directly; ESC returns to the main menu.
## Wizard (the baseline = pre-difficulty balance) starts selected.
extends Control

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")
const BTN_ACTIVE: Texture2D = preload("res://assets/ui/btn_active.png")
const BTN_INACTIVE: Texture2D = preload("res://assets/ui/btn_inactive.png")

const ROOM_01 := "res://rooms/room_01.tscn"
const MAIN_MENU := "res://ui/menu/main_menu.tscn"

const BG := Color(0.09, 0.08, 0.11)
const TEXT := Color(0.93, 0.92, 0.95)
const MUTED := Color(0.62, 0.6, 0.66)

# Flavor text: placeholder in the intro's tone of voice — Design to bless
# (Spec 018 open question). Every desc restates that countdowns never change.
const ITEMS: Array[Dictionary] = [
	{
		"label": "APPRENTICE", "hotkey": "1", "keycode": KEY_1,
		"resource": preload("res://systems/difficulty/apprentice.tres"),
		"desc": "For apprentices still learning which end of the bag opens.\n\n" +
			"More hearts, gentler enemies. The countdowns tick just the same.",
	},
	{
		"label": "WIZARD", "hotkey": "2", "keycode": KEY_2,
		"resource": preload("res://systems/difficulty/wizard.tres"),
		"desc": "The tower exactly as Violet arranged it.\n\n" +
			"Five hearts, honest enemies. The intended climb.",
	},
	{
		"label": "ARCHMAGE", "hotkey": "3", "keycode": KEY_3,
		"resource": preload("res://systems/difficulty/archmage.tres"),
		"desc": "For masters who juggle lit bombs for fun.\n\n" +
			"Fewer hearts; faster, sharper enemies. Same countdowns — no excuses.",
	},
]

var _selected: int = 1  # Wizard: the baseline is the default
var _rows: Array[TextureRect] = []
var _desc: Label


func _ready() -> void:
	_build()
	_refresh()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _label("CHOOSE YOUR CHALLENGE", FONT_BOLD, 30, TEXT)
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

	_desc = _label("", FONT_REG, 16, MUTED)
	_desc.position = Vector2(470, 140)
	_desc.custom_minimum_size = Vector2(280, 0)
	_desc.size.x = 280.0
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_desc)

	var nav := _label("[W/S] / [UP/DOWN] NAVIGATE MENU", FONT_REG, 12, MUTED)
	nav.position = Vector2(80, 688)
	add_child(nav)
	var sel := _label("[SPACE/ENTER] START  [ESC] BACK", FONT_REG, 12, MUTED)
	sel.position = Vector2(980, 688)
	add_child(sel)


func _refresh() -> void:
	for i in _rows.size():
		var active := i == _selected
		_rows[i].texture = BTN_ACTIVE if active else BTN_INACTIVE
		_rows[i].custom_minimum_size.x = 360.0 if active else 320.0
		_rows[i].size.x = _rows[i].custom_minimum_size.x
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
			KEY_ESCAPE:
				AudioManager.play_sfx(&"button_clicked")
				get_tree().change_scene_to_file(MAIN_MENU)
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
	GameState.difficulty = ITEMS[index]["resource"]
	GameState.reset_run()
	get_tree().change_scene_to_file(ROOM_01)


func _label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label
