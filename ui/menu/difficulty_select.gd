## Difficulty select (Spec 018), shown after New Game. Same code-driven,
## wooden-button pattern as the main menu: W/S or arrows to move, Enter/Space
## to select, or a level's number directly; ESC returns to the main menu.
## Wizard (the baseline = pre-difficulty balance) starts selected.
## Spec 022 redesign: brick backdrop + banner, built on the MenuUI helper.
extends Control

const FIRST_LEVEL := "res://rooms/level.tscn"
const INTRO_CUTSCENE := "res://ui/cutscene/intro_cutscene.tscn"
const MAIN_MENU := "res://ui/menu/main_menu.tscn"

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
var _keys: Array[Label] = []
var _desc: Label


func _ready() -> void:
	AudioManager.play_music(&"menu")
	_build()
	_refresh()


func _build() -> void:
	MenuUI.brick(self)
	MenuUI.image(self, MenuUI.CROW, Vector2(760, 150), Vector2(440, 440))

	# panel() (fill) not parchment() (keep-aspect) so the sign is wide enough
	# for the long title without the torn edges clipping the text.
	MenuUI.panel(self, MenuUI.BANNER, Vector2(40, 22), Vector2(560, 150))
	var title := MenuUI.label("CHOOSE YOUR CHALLENGE", MenuUI.FONT_BOLD, 22, MenuUI.INK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size.x = 560.0
	title.position = Vector2(40, 84)
	add_child(title)

	for i in ITEMS.size():
		var row := MenuUI.button_row(self, ITEMS[i]["label"], Vector2(80, 210 + i * 58))
		var key_label := MenuUI.label("[%s]" % ITEMS[i]["hotkey"], MenuUI.FONT_REG, 14, MenuUI.LIGHT_MUTED)
		key_label.position = Vector2(258, 13)
		row.add_child(key_label)
		_rows.append(row)
		_keys.append(key_label)

	# Description beside the buttons, its top aligned to the first button.
	_desc = MenuUI.label("", MenuUI.FONT_REG, 16, MenuUI.LIGHT_MUTED)
	_desc.position = Vector2(470, 214)
	_desc.size.x = 260.0
	_desc.custom_minimum_size = Vector2(260, 0)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_desc)

	MenuUI.label_at(self, "[W/S] / [UP/DOWN] NAVIGATE MENU", MenuUI.FONT_REG, 12,
			MenuUI.LIGHT_MUTED, Vector2(80, 688))
	var sel := MenuUI.label("[SPACE/ENTER] START  [ESC] BACK", MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED)
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
	# The story beat is the last thing before play (Spec 023); once per launch,
	# so replaying a run drops you straight into the tower.
	get_tree().change_scene_to_file(FIRST_LEVEL if GameState.intro_seen else INTRO_CUTSCENE)
