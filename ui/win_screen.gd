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


## Where "climb again" leads: floor 1 of the real run, never the room_01/02 smoke
## fixtures. Split out so the smoke test can assert the destination without
## triggering a scene change (which would tear down the test container).
func restart_target() -> String:
	return RunManager.LEVEL_SCENE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		# reset_run() puts current_room back to 0, so the shared level scene
		# rebuilds itself as level 1.
		GameState.reset_run()
		get_tree().change_scene_to_file(restart_target())
