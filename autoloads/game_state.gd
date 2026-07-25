## Run-level state (autoload "GameState").
## Holds no references to freeable scene nodes — communicate via EventBus.
extends Node

## 1 tile = 32 px (team decision, 2026-07-25). All tile-unit gameplay
## distances (throw range, radii, kick, detection) convert through this.
const TILE_SIZE: int = 32

var current_room: int = 0
## Carries player health across room transitions; -1 means "full health".
var player_health: int = -1


func reset_run() -> void:
	current_room = 0
	player_health = -1


func tiles(count: float) -> float:
	return count * TILE_SIZE
