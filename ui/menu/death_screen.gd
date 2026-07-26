## Death screen (autoload "DeathScreen"). On player death: freeze the game,
## fade in a "YOU DIED" overlay in the game's typography, hold a few seconds,
## then return to the main menu. Listens to EventBus.player_died.
extends CanvasLayer

const FONT_BOLD: FontFile = preload("res://assets/fonts/Dellas-Bold.otf")
const MAIN_MENU := "res://ui/menu/main_menu.tscn"

const HOLD_SECONDS := 3.2

var _root: Control
var _label: Label
var _showing: bool = false


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_root.visible = false
	EventBus.player_died.connect(_on_player_died)


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.04, 0.82)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	_label = Label.new()
	_label.text = "YOU DIED"
	_label.add_theme_font_override("font", FONT_BOLD)
	_label.add_theme_font_size_override("font_size", 72)
	_label.add_theme_color_override("font_color", Color(0.86, 0.14, 0.16))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_label)


func _on_player_died() -> void:
	if _showing:
		return
	_showing = true
	AudioManager.play_sfx(&"game_over")
	_root.modulate.a = 0.0
	_root.visible = true
	get_tree().paused = true
	var fade := create_tween()
	fade.tween_property(_root, "modulate:a", 1.0, 0.5)
	# create_timer ticks while paused (process_always defaults true).
	await get_tree().create_timer(HOLD_SECONDS).timeout
	get_tree().paused = false
	_root.visible = false
	_showing = false
	GameState.reset_run()
	get_tree().change_scene_to_file(MAIN_MENU)
