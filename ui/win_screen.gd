## End-of-run placeholder (Spec 007). Attack restarts the run.
extends Control

@onready var _hint: Label = $Hint


func _ready() -> void:
	# Show the actual keyboard key (from the InputMap), not a gamepad glyph.
	_hint.text = "Press %s to climb again" % _attack_key()


func _attack_key() -> String:
	for ev in InputMap.action_get_events("attack"):
		if ev is InputEventKey:
			return OS.get_keycode_string((ev as InputEventKey).physical_keycode)
	return "Attack"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		GameState.reset_run()
		get_tree().change_scene_to_file("res://rooms/room_01.tscn")
