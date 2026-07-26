## Options screen (Spec 022 redesign): resolution + fullscreen, and a read-only
## view of the control bindings (pulled from the live InputMap). ESC returns to
## the menu. Brick backdrop + parchment panels; logic unchanged from Spec 013.
extends Control

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080),
]


func _ready() -> void:
	AudioManager.play_music(&"menu")
	_build()


func _build() -> void:
	MenuUI.brick(self)

	MenuUI.label_at(self, "OPTIONS", MenuUI.FONT_BOLD, 34, MenuUI.LIGHT, Vector2(80, 48))

	# --- Resolution panel ---
	MenuUI.panel(self, MenuUI.BANNER, Vector2(80, 118), Vector2(600, 190))
	MenuUI.label_at(self, "RESOLUTION", MenuUI.FONT_BOLD, 20, MenuUI.INK, Vector2(120, 148))
	MenuUI.label_at(self, "SCREEN RESOLUTION (16:9)", MenuUI.FONT_REG, 12, MenuUI.INK_MUTED, Vector2(120, 186))
	var res := OptionButton.new()
	res.position = Vector2(120, 210)
	res.custom_minimum_size = Vector2(520, 30)
	for r in RESOLUTIONS:
		res.add_item("%d X %d" % [r.x, r.y])
	res.add_theme_font_override("font", MenuUI.FONT_REG)
	res.item_selected.connect(_on_resolution_selected)
	add_child(res)
	MenuUI.label_at(self, "FULLSCREEN", MenuUI.FONT_REG, 13, MenuUI.INK, Vector2(120, 258))
	var fs := CheckButton.new()
	fs.position = Vector2(560, 248)
	fs.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect(_on_fullscreen_toggled)
	add_child(fs)

	# --- Controls panel ---
	MenuUI.panel(self, MenuUI.BANNER, Vector2(80, 330), Vector2(600, 300))
	MenuUI.label_at(self, "CONTROLS", MenuUI.FONT_BOLD, 20, MenuUI.INK, Vector2(120, 356))
	var rows := [
		["MOVEMENT", "W / A / S / D"],
		["DRAW / THROW ITEM", _keys_for("attack")],
		["DODGE", _keys_for("dash")],
		["KICK", _keys_for("special")],
		["PAUSE", "ESC"],
	]
	for i in rows.size():
		var y := 400.0 + i * 40.0
		MenuUI.label_at(self, rows[i][0], MenuUI.FONT_REG, 14, MenuUI.INK_MUTED, Vector2(120, y))
		MenuUI.label_at(self, rows[i][1], MenuUI.FONT_SEMI, 14, MenuUI.INK, Vector2(420, y))

	MenuUI.label_at(self, "[ESC] BACK", MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED, Vector2(80, 688))


func _on_resolution_selected(index: int) -> void:
	var r := RESOLUTIONS[index]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(r)


func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MAIN_MENU)


func _keys_for(action: String) -> String:
	var parts: Array[String] = []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			parts.append(OS.get_keycode_string((ev as InputEventKey).physical_keycode))
	return " / ".join(parts)
