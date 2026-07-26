## Options screen (Spec 022 redesign + volume). Resolution + fullscreen, audio
## volume sliders (Master / Music / SFX), and a read-only control list (from the
## live InputMap). ESC returns to the menu — or, when embedded in the pause
## overlay, closes back to the pause menu without losing the run.
extends Control

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

## Emitted when ESC is pressed while embedded (the pause overlay listens).
signal closed

## Set true by the pause menu before adding this as an overlay: keep the run,
## don't switch music, and route ESC back to pause instead of the main menu.
var embedded: bool = false

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080),
]

const VOLUME_ROWS: Array = [
	{"key": &"master", "label": "MASTER"},
	{"key": &"music", "label": "MUSIC"},
	{"key": &"sfx", "label": "SFX"},
]


func _ready() -> void:
	if not embedded:
		AudioManager.play_music(&"menu")
	_build()


func _build() -> void:
	MenuUI.brick(self)
	MenuUI.label_at(self, "OPTIONS", MenuUI.FONT_BOLD, 34, MenuUI.LIGHT, Vector2(80, 44))

	# --- Resolution panel (top-left) ---
	MenuUI.panel(self, MenuUI.BANNER, Vector2(80, 104), Vector2(560, 170))
	MenuUI.label_at(self, "RESOLUTION", MenuUI.FONT_BOLD, 20, MenuUI.INK, Vector2(120, 130))
	var res := OptionButton.new()
	res.position = Vector2(120, 168)
	res.custom_minimum_size = Vector2(300, 30)
	for r in RESOLUTIONS:
		res.add_item("%d X %d" % [r.x, r.y])
	res.add_theme_font_override("font", MenuUI.FONT_REG)
	res.item_selected.connect(_on_resolution_selected)
	add_child(res)
	MenuUI.label_at(self, "FULLSCREEN", MenuUI.FONT_REG, 14, MenuUI.INK, Vector2(120, 214))
	var fs := CheckButton.new()
	fs.position = Vector2(500, 204)
	fs.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect(_on_fullscreen_toggled)
	add_child(fs)

	# --- Audio panel (below resolution) ---
	MenuUI.panel(self, MenuUI.BANNER, Vector2(80, 296), Vector2(560, 240))
	MenuUI.label_at(self, "AUDIO", MenuUI.FONT_BOLD, 20, MenuUI.INK, Vector2(120, 322))
	for i in VOLUME_ROWS.size():
		var y := 372.0 + i * 50.0
		MenuUI.label_at(self, VOLUME_ROWS[i]["label"], MenuUI.FONT_REG, 15, MenuUI.INK, Vector2(120, y))
		var key: StringName = VOLUME_ROWS[i]["key"]
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = AudioManager.get_volume(key)
		slider.custom_minimum_size = Vector2(300, 24)
		slider.position = Vector2(260, y + 2.0)
		var pct := MenuUI.label_at(self, _pct(slider.value), MenuUI.FONT_REG, 14, MenuUI.INK_MUTED, Vector2(578, y))
		slider.value_changed.connect(func(v: float) -> void:
			AudioManager.set_volume(key, v)
			pct.text = _pct(v))
		add_child(slider)

	# --- Controls panel (right column) ---
	MenuUI.panel(self, MenuUI.BANNER, Vector2(680, 104), Vector2(520, 432))
	MenuUI.label_at(self, "CONTROLS", MenuUI.FONT_BOLD, 20, MenuUI.INK, Vector2(720, 130))
	var rows := [
		["MOVEMENT", "W / A / S / D"],
		["DRAW / THROW ITEM", _keys_for("attack")],
		["DODGE", _keys_for("dash")],
		["KICK", _keys_for("special")],
		["PAUSE", "ESC"],
	]
	for i in rows.size():
		var y := 180.0 + i * 46.0
		MenuUI.label_at(self, rows[i][0], MenuUI.FONT_REG, 14, MenuUI.INK_MUTED, Vector2(720, y))
		MenuUI.label_at(self, rows[i][1], MenuUI.FONT_SEMI, 14, MenuUI.INK, Vector2(1000, y))

	var back := "[ESC] BACK" if not embedded else "[ESC] BACK TO PAUSE"
	MenuUI.label_at(self, back, MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED, Vector2(80, 688))


func _pct(value: float) -> String:
	return "%d%%" % roundi(value * 100.0)


func _on_resolution_selected(index: int) -> void:
	var r := RESOLUTIONS[index]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(r)


func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		if embedded:
			get_viewport().set_input_as_handled()
			closed.emit()
		else:
			get_tree().change_scene_to_file(MAIN_MENU)


func _keys_for(action: String) -> String:
	var parts: Array[String] = []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			parts.append(OS.get_keycode_string((ev as InputEventKey).physical_keycode))
	return " / ".join(parts)
