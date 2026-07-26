## Run-level state (autoload "GameState").
## Holds no references to freeable scene nodes — communicate via EventBus.
extends Node

## 1 tile = 32 px (team decision, 2026-07-25). All tile-unit gameplay
## distances (throw range, radii, kick, detection) convert through this.
const TILE_SIZE: int = 32

var current_room: int = 0
## Carries player health across room transitions; -1 means "full health".
var player_health: int = -1

## Active difficulty (Spec 018). Defaults to Wizard = today's exact balance,
## so every entry path that skips the select screen (smoke test, direct scene
## runs) behaves identically to before. Set by the difficulty select screen;
## survives reset_run() so death/restart keeps the player's choice.
var difficulty: DifficultyResource = preload("res://systems/difficulty/wizard.tres")

## Full item catalog — the doors' offer pool (Spec 017).
const ITEM_CATALOG: Array[MagicItemResource] = [
	preload("res://systems/magic_items/fire_orb.tres"),
	preload("res://systems/magic_items/right_hand_of_ursula.tres"),
	preload("res://systems/magic_items/left_hand_of_ursula.tres"),
	preload("res://systems/magic_items/troy_wooden_horse.tres"),
	preload("res://systems/magic_items/atomic_orb.tres"),
	preload("res://systems/magic_items/magnetic_horseshoe.tres"),
]

## Intro cutscene shown at least once this launch (Spec 023). Session-only —
## no save system — so repeat testers and jam judges aren't forced to rewatch,
## but a fresh launch always tells the story.
var intro_seen: bool = false

## The run's draw pool (Spec 017): starts at Fire Orb, grows via door pickups.
## Empty = "no run active" — the Bag then falls back to its static .tres pool
## (dev scene runs and the smoke test's injected pools keep working).
var run_pool: Array[MagicItemResource] = []


## Adds an item to the run's pool. Returns false (no-op) when already owned —
## the duplicate door is the player's "no thanks" option (team, 2026-07-27).
func unlock_item(item_data: MagicItemResource) -> bool:
	if item_data == null or run_pool.has(item_data):
		return false
	run_pool.append(item_data)
	return true


func reset_run() -> void:
	current_room = 0
	player_health = -1
	run_pool = [ITEM_CATALOG[0]]  # Fire Orb: the starter


func tiles(count: float) -> float:
	return count * TILE_SIZE
