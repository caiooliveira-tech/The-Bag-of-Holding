## Credits screen (Spec 022 redesign). Brick backdrop, credits list on the left,
## the logo on a big scroll to the right. ESC returns to the menu.
extends Control

const MAIN_MENU := "res://ui/menu/main_menu.tscn"

# Names as the team wrote them in the mock; roles filled from their fronts.
const ENTRIES: Array[Dictionary] = [
	{"name": "Silas Chosen", "role": "Art, tiles, monster design, Game Designer"},
	{"name": "Caio Goncalves dos Santos Curintxa", "role": "Programming, game systems and Game Designer"},
	{"name": "RH da Silva Sauro", "role": "Programming, enemy AI"},
	{"name": "Flavio Lee Budoia", "role": "UI/HUD design, level layouts"},
	{"name": "Heitor Mendes dos Santos", "role": "Tester"},
	{"name": "Coffee, sweat, tears and fun", "role": "The fuel that drive us all."},
	{"name": "Xuxa e Sasha", "role": "Um beijo. E outro especialmente pra voce."},
]


func _ready() -> void:
	AudioManager.play_music(&"menu")
	MenuUI.brick(self)

	# Big scroll with the logo, right side.
	MenuUI.parchment(self, MenuUI.SCROLL, Vector2(720, 100), Vector2(500, 500))
	MenuUI.image(self, MenuUI.LOGO, Vector2(800, 260), Vector2(340, 200))

	MenuUI.label_at(self, "CREDITS", MenuUI.FONT_BOLD, 34, MenuUI.LIGHT, Vector2(80, 60))

	for i in ENTRIES.size():
		var y := 150.0 + i * 62.0
		MenuUI.label_at(self, ENTRIES[i]["name"], MenuUI.FONT_BOLD, 16, MenuUI.LIGHT, Vector2(80, y))
		MenuUI.label_at(self, ENTRIES[i]["role"], MenuUI.FONT_REG, 13, MenuUI.LIGHT_MUTED, Vector2(80, y + 24))

	MenuUI.label_at(self, "[ESC] BACK", MenuUI.FONT_REG, 12, MenuUI.LIGHT_MUTED, Vector2(80, 688))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(MAIN_MENU)
