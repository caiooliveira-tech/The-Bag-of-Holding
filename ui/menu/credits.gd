## Credits screen (new scene). ESC returns to the menu.
extends Control

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const FONT_REG: FontFile = preload("res://assets/fonts/Dellas-Regular.otf")

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

const BG := Color(0.08, 0.07, 0.12)
const TEXT := Color(0.93, 0.92, 0.95)
const MUTED := Color(0.62, 0.6, 0.66)

# Names as the team wrote them in the mock; roles filled from their fronts.
const ENTRIES: Array[Dictionary] = [
	{"name": "Silas Chosen", "role": "Art, tiles, monster design"},
	{"name": "Caio Goncalves dos Santos Curintxa", "role": "Programming, game systems"},
	{"name": "RH da Silva Sauro", "role": "Programming, enemy AI"},
	{"name": "Flavio Lee Budoia", "role": "UI/HUD design, level layouts"},
	{"name": "Coffee, sweat, tears and fun", "role": "The fuel that drive us all."},
	{"name": "Xuxa e Sasha", "role": "Um beijo. E outro especialmente pra voce."},
]


func _ready() -> void:
	AudioManager.play_music(&"menu")
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := _label("CREDITS", FONT_BOLD, 30, TEXT)
	title.position = Vector2(80, 60)
	add_child(title)

	for i in ENTRIES.size():
		var y := 140.0 + i * 58.0
		var name_label := _label(ENTRIES[i]["name"], FONT_BOLD, 15, TEXT)
		name_label.position = Vector2(80, y)
		add_child(name_label)
		var role_label := _label(ENTRIES[i]["role"], FONT_REG, 13, MUTED)
		role_label.position = Vector2(80, y + 22)
		add_child(role_label)

	var back := _label("[ESC] BACK", FONT_REG, 12, MUTED)
	back.position = Vector2(1120, 688)
	add_child(back)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MAIN_MENU)


func _label(text: String, font: FontFile, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label
