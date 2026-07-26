## Throwaway integration check: does walking through a door that offers a NEW
## item actually trigger the ItemAcquired screen? Run headless, prints result.
extends Node

const URSULA := preload("res://systems/magic_items/right_hand_of_ursula.tres")


func _ready() -> void:
	_run()


func _run() -> void:
	GameState.reset_run()  # run_pool = [fire_orb]
	var room := (load("res://rooms/room_01.tscn") as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().physics_frame

	# Clear the room the way gameplay does: announce each enemy's death.
	for e in get_tree().get_nodes_in_group("enemies"):
		EventBus.enemy_died.emit(e)
		e.queue_free()
	await get_tree().process_frame

	var doors: Array = room.get_node("Doors").get_children()
	var door = doors[0]
	print("door count=%d, offered after clear=%s" % [doors.size(),
			door.offered_item.id if door.offered_item != null else "<null>"])

	# Force a NEW item on this door (not owned), then walk the player through.
	door.set_offer(URSULA)
	var player = room.get_node("Player")
	door.player_entered.emit(player)
	await get_tree().process_frame

	var acquired := get_node("/root/ItemAcquired")
	print("RESULT: item_acquired active=%s, tree paused=%s, run_pool has ursula=%s" % [
			acquired._active, get_tree().paused, GameState.run_pool.has(URSULA)])
	get_tree().paused = false
	get_tree().quit()
