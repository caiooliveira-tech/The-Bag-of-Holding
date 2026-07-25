## freeze_area effect_type (Right Hand of Ursula).
## Movement-lock only (team decision 2026-07-25): frozen characters still
## attack and still take damage — crowd control, not an action-lock.
class_name FreezeAreaEffect
extends MagicItemEffect

const EFFECT_FLASH_SCRIPT: GDScript = preload("res://systems/magic_items/effects/effect_flash.gd")

## Bodies are treated as points; pad the radius so a body visually touching
## the circle still counts (half a graybox body).
const TARGET_PADDING_PX: float = 12.0

@export var radius_tiles: float = 1.0
@export var freeze_duration_seconds: float = 5.0


func execute(item: Node2D) -> Array[Node]:
	var radius_px: float = GameState.tiles(radius_tiles) + TARGET_PADDING_PX
	var affected: Array[Node] = []
	var targets: Array[Node] = item.get_tree().get_nodes_in_group("enemies")
	targets.append_array(item.get_tree().get_nodes_in_group("player"))
	for target in targets:
		var body := target as Node2D
		if body == null or body.global_position.distance_to(item.global_position) > radius_px:
			continue
		affected.append(target)
		if target.is_in_group("enemies"):
			(target as Enemy).freeze(freeze_duration_seconds)
		else:
			(target as Player).freeze(freeze_duration_seconds)
	var flash := EFFECT_FLASH_SCRIPT.new() as Node2D
	item.get_tree().current_scene.add_child(flash)
	flash.global_position = item.global_position
	flash.setup(radius_px, Color(0.55, 0.85, 1.0, 0.45))
	return affected
