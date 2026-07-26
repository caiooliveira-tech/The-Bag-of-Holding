## Dev utility: captures both room scenes to PNG for visual review.
## Run: Godot.exe --path . res://tests/screenshot_rooms.tscn -- <output_dir>
extends Node

const ROOMS: Array[String] = [
	"res://rooms/room_01.tscn",
	"res://rooms/room_02.tscn",
]


func _ready() -> void:
	_run()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir := args[0] if args.size() > 0 else OS.get_user_data_dir()
	for room_path in ROOMS:
		var room := (load(room_path) as PackedScene).instantiate()
		add_child(room)
		# Let tiles paint, doors apply textures and a couple of frames render.
		await get_tree().create_timer(0.6).timeout
		var image := get_viewport().get_texture().get_image()
		var out_path := out_dir.path_join(room_path.get_file().get_basename() + ".png")
		image.save_png(out_path)
		print("saved: " + out_path)
		room.queue_free()
		await get_tree().process_frame
	get_tree().quit()
