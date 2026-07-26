## The run's level order (autoload "RunManager", Spec 016). Owns the twelve
## LevelResources and answers "which floor am I on?" using GameState.current_room.
## Holds no scene references — the level scene asks, builds itself, and leaves.
extends Node

const LEVELS: Array[LevelResource] = [
	preload("res://systems/run/levels/level_01.tres"),
	preload("res://systems/run/levels/level_02.tres"),
	preload("res://systems/run/levels/level_03.tres"),
	preload("res://systems/run/levels/level_04.tres"),
	preload("res://systems/run/levels/level_05.tres"),
	preload("res://systems/run/levels/level_06.tres"),
	preload("res://systems/run/levels/level_07.tres"),
	preload("res://systems/run/levels/level_08.tres"),
	preload("res://systems/run/levels/level_09.tres"),
	preload("res://systems/run/levels/level_10.tres"),
	preload("res://systems/run/levels/level_11.tres"),
	preload("res://systems/run/levels/level_12.tres"),
]

const LEVEL_SCENE := "res://rooms/level.tscn"
const WIN_SCENE := "res://ui/win_screen.tscn"


func level_count() -> int:
	return LEVELS.size()


## The floor the player is on. Clamped so a stray index can never crash a run.
func current_level() -> LevelResource:
	return LEVELS[clampi(GameState.current_room, 0, LEVELS.size() - 1)]


func is_last_level() -> bool:
	return GameState.current_room >= LEVELS.size() - 1


## Where a door leads: the next floor (same scene, new data) or the win screen.
func next_scene_path() -> String:
	return WIN_SCENE if is_last_level() else LEVEL_SCENE
