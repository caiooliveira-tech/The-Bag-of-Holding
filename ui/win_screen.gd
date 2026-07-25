## End-of-run placeholder (Spec 007). Attack restarts the run.
extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		GameState.reset_run()
		get_tree().change_scene_to_file("res://rooms/room_01.tscn")
