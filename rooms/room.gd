## Room controller (Spec 007): WAITING (telegraph) -> COMBAT -> CLEARED.
## The room is the only thing that counts enemies; door and enemies stay dumb.
class_name Room
extends Node2D

enum State { WAITING, COMBAT, CLEARED }

## Preloaded by path (not class_name) so CLI runs don't depend on the
## editor's global class cache having scanned this fresh script pair.
const DOOR_SCRIPT: GDScript = preload("res://rooms/door.gd")

@export_file("*.tscn") var next_scene_path: String = ""
@export var telegraph_seconds: float = 1.0
## Announced by the drop-in Level Title sign on entry (Spec 022). Empty = no sign.
@export var level_title: String = ""

var state: State = State.WAITING

var _enemies_alive: int = 0

@onready var _doors: Array[Node] = $Doors.get_children()


func _ready() -> void:
	AudioManager.play_music(&"in_game")
	EventBus.level_entered.emit(level_title)
	EventBus.enemy_died.connect(_on_enemy_died)
	for node in _doors:
		(node as DOOR_SCRIPT).player_entered.connect(_on_player_entered_door)
	var enemies := get_tree().get_nodes_in_group("enemies")
	_enemies_alive = enemies.size()
	for node in enemies:
		(node as Enemy).set_active(false)
	_begin_combat_after_telegraph()


func _begin_combat_after_telegraph() -> void:
	await get_tree().create_timer(telegraph_seconds).timeout
	if state != State.WAITING:
		return
	state = State.COMBAT
	for node in get_tree().get_nodes_in_group("enemies"):
		(node as Enemy).set_active(true)


func _on_enemy_died(_enemy: Node) -> void:
	_enemies_alive -= 1
	if _enemies_alive <= 0 and state != State.CLEARED:
		state = State.CLEARED
		EventBus.room_cleared.emit()
		# MVP: every door opens and leads to the same next room; the
		# pick-a-door power-up choice is post-MVP (see Spec 007).
		for node in _doors:
			(node as DOOR_SCRIPT).open()


func _on_player_entered_door(player: Player) -> void:
	if next_scene_path.is_empty():
		return
	GameState.player_health = player.health
	GameState.current_room += 1
	get_tree().change_scene_to_file.bind(next_scene_path).call_deferred()
