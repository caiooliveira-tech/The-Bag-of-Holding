## Dev utility: captures the front-end screens to PNG for visual review.
## Run: Godot.exe --path . res://tests/screenshot_screens.tscn -- <output_dir>
extends Node

const SCREENS: Array[String] = [
	"res://ui/menu/title_screen.tscn",
	"res://ui/menu/main_menu.tscn",
	"res://ui/menu/options_menu.tscn",
	"res://ui/menu/credits.tscn",
	"res://ui/menu/difficulty_select.tscn",
]


func _ready() -> void:
	_run()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir := args[0] if args.size() > 0 else OS.get_user_data_dir()

	for path in SCREENS:
		var screen := (load(path) as PackedScene).instantiate()
		add_child(screen)
		await get_tree().create_timer(0.9).timeout  # fades/tweens settle
		_save(out_dir, path.get_file().get_basename())
		screen.queue_free()
		await get_tree().process_frame

	# Level Title sign over room_01: capture mid-hold.
	var room := (load("res://rooms/room_01.tscn") as PackedScene).instantiate()
	add_child(room)
	await get_tree().create_timer(0.7).timeout
	_save(out_dir, "level_title")

	# Pause menu over the same room (open it directly on the Pause autoload).
	await get_tree().create_timer(1.6).timeout  # let the sign lift out first
	var pause := get_node("/root/Pause")
	pause.call("_pause")
	await get_tree().create_timer(0.5).timeout
	_save(out_dir, "pause_menu")

	# Options opened FROM pause = an embedded overlay (bug-fix check): it must
	# show, and closing it must return to pause with the run still paused.
	pause.call("_activate", 1)  # OPTIONS row
	await get_tree().create_timer(0.4).timeout
	_save(out_dir, "pause_options")
	pause.call("_close_options")
	await get_tree().create_timer(0.3).timeout
	print("after close: paused=%s, still gameplay=%s" % [
		get_tree().paused, get_tree().get_first_node_in_group("player") != null])
	_save(out_dir, "pause_after_close")

	pause.call("_resume")

	# HUD held-item box: fill it with the longest item name to check it fits.
	var ursula := load("res://systems/magic_items/right_hand_of_ursula.tres") as MagicItemResource
	EventBus.item_drawn.emit(ursula)
	await get_tree().create_timer(0.4).timeout
	_save(out_dir, "hud_long_item")

	# Item-acquired scroll (empty next path = don't change scene on continue).
	var acquired := get_node("/root/ItemAcquired")
	acquired.call("show_and_continue", ursula, "")
	await get_tree().create_timer(0.6).timeout
	_save(out_dir, "item_acquired")
	acquired.call("_continue")
	await get_tree().process_frame

	room.queue_free()
	await get_tree().process_frame

	get_tree().quit()


func _save(out_dir: String, name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var out_path := out_dir.path_join(name + ".png")
	image.save_png(out_path)
	print("saved: " + out_path)
