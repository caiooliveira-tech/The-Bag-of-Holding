## magnet_area effect_type (Magnetic Horseshoe, Spec 020 v2).
## The anti-Left-Hand: everyone in the radius — enemies AND the player —
## is yanked onto the magnet and glued into a MagnetCluster that moves as
## one for `cluster_duration_seconds`, then releases. A glued player eats
## contact melee (pillar 4); subsequent items hit the whole blob.
class_name MagnetAreaEffect
extends MagicItemEffect

const EFFECT_FLASH_SCRIPT: GDScript = preload("res://systems/magic_items/effects/effect_flash.gd")
const CLUSTER_SCRIPT: GDScript = preload("res://systems/magic_items/effects/magnet_cluster.gd")

## Bodies are treated as points; pad the radius so a body visually touching
## the circle still counts (half a graybox body).
const TARGET_PADDING_PX: float = 12.0
## Initial yank: impulse scale toward the magnet point (arrives in ~0.15 s).
const YANK_GAIN: float = 7.0

@export var radius_tiles: float = 3.0
@export var cluster_duration_seconds: float = 5.0


func effect_kind() -> StringName:
	return &"magnet_area"


func preview_radius_tiles() -> float:
	return radius_tiles


func execute(item: Node2D) -> Array[Node]:
	var radius_px: float = GameState.tiles(radius_tiles) + TARGET_PADDING_PX
	var members: Array[Node2D] = []
	var affected: Array[Node] = []
	var targets: Array[Node] = item.get_tree().get_nodes_in_group("enemies")
	targets.append_array(item.get_tree().get_nodes_in_group("player"))
	for target in targets:
		var body := target as Node2D
		if body == null or body.global_position.distance_to(item.global_position) > radius_px:
			continue
		if wall_blocks(item, body.global_position):
			continue
		members.append(body)
		affected.append(target)
		body.call(&"apply_knockback",
				(item.global_position - body.global_position) * YANK_GAIN)
	if not members.is_empty():
		var cluster := CLUSTER_SCRIPT.new() as MagnetCluster
		item.get_tree().current_scene.add_child(cluster)
		cluster.global_position = item.global_position
		cluster.setup(members, cluster_duration_seconds)
	var flash := EFFECT_FLASH_SCRIPT.new() as Node2D
	item.get_tree().current_scene.add_child(flash)
	flash.global_position = item.global_position
	flash.setup(radius_px, Color(0.75, 0.72, 0.8, 0.45))
	return affected
