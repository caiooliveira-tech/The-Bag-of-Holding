## Throwaway: render specific cutscene frames to PNG for layout review.
extends Node


func _ready() -> void:
	_run()


func _run() -> void:
	var out_dir := OS.get_cmdline_user_args()[0]
	var scene := (load("res://ui/cutscene/intro_cutscene.tscn") as PackedScene).instantiate()
	add_child(scene)
	await get_tree().process_frame
	var frames = scene.cutscene.frames
	# Dialogue frames worth checking: the "trapped" beat + a long 3-liner.
	for idx in [8, 11]:
		scene.call("_show_frame", frames[idx])
		scene.call("_complete_reveal")
		await get_tree().create_timer(0.3).timeout
		var img := get_viewport().get_texture().get_image()
		img.save_png(out_dir.path_join("cutscene_%d.png" % idx))
		print("saved cutscene_%d (%s)" % [idx, frames[idx].text.substr(0, 24)])
	get_tree().quit()
