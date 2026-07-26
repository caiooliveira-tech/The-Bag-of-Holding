## Options screen (new scene): resolution + fullscreen, and a read-only view of
## the control bindings (pulled from the live InputMap). ESC returns to the menu.
extends Control

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

const BG := Color(0.08, 0.07, 0.12)
const PANEL := Color(0.14, 0.12, 0.2)
const TEXT := Color(0.93, 0.92, 0.95)
const MUTED := Color(0.62, 0.6, 0.66)

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080),
]


func _ready() -> void:
	AudioManager.play_music(&"menu")
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _label("OPTIONS", FONT_BOLD, 30, TEXT)
	title.position = Vector2(80, 70)
	add_child(title)

	# --- Resolution panel ---
	_panel(Vector2(80, 150), Vector2(560, 150))
	_label_at("RESOLUTION", FONT_BOLD, 18, TEXT, Vector2(100, 168))
	_label_at("SCREEN_RESOLUTION_RATIO", FONT_REG, 12, MUTED, Vector2(100, 205))
	var res := OptionButton.new()
	res.position = Vector2(100, 224)
	res.custom_minimum_size = Vector2(520, 28)
	for r in RESOLUTIONS:
		res.add_item("%d X %d [16:9]" % [r.x, r.y])
	res.add_theme_font_override("font", FONT_REG)
	res.item_selected.connect(_on_resolution_selected)
	add_child(res)
	_label_at("FULLSCREEN_DISPLAY", FONT_REG, 12, MUTED, Vector2(100, 262))
	var fs := CheckButton.new()
	fs.position = Vector2(480, 252)
	fs.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect(_on_fullscreen_toggled)
	add_child(fs)

	# --- Controls panel ---
	_panel(Vector2(80, 320), Vector2(560, 210))
	_label_at("CONTROLS", FONT_BOLD, 18, TEXT, Vector2(100, 338))
	var rows := [
		["MOVEMENT", "W / A / S / D"],
		["DRAW / THROW ITEM", _keys_for("attack")],
		["DODGE", _keys_for("dash")],
		["KICK", _keys_for("special")],
	]
	for i in rows.size():
		var y := 378.0 + i * 34.0
		_label_at(rows[i][0], FONT_REG, 13, MUTED, Vector2(100, y))
		_label_at(rows[i][1], FONT_REG, 13, TEXT, Vector2(460, y))

	_label_at("[ESC] BACK", FONT_REG, 12, MUTED, Vector2(80, 688))


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


func _panel(pos: Vector2, sz: Vector2) -> void:
	var p := ColorRect.new()
	p.color = PANEL
	p.position = pos
	p.size = sz
	add_child(p)


func _label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _label_at(text: String, font: FontFile, size: int, color: Color, pos: Vector2) -> void:
	var label := _label(text, font, size, color)
	label.position = pos
	add_child(label)
