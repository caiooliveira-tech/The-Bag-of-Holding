## knockback_area effect_type (Left Hand of Ursula, Spec 011).
## Shoves every character in radius away from the blast center. Affects the
## player too (pillar 4). A new subclass — the base framework is untouched.
class_name KnockbackAreaEffect
extends MagicItemEffect

const IMPACT_BURST: GDScript = preload("res://systems/juice/impact_burst.gd")
const EXPANDING_RING: GDScript = preload("res://systems/juice/expanding_ring.gd")

## Bodies are treated as points; pad the radius so a body visually touching
## the circle still counts (half a graybox body).
const TARGET_PADDING_PX: float = 12.0

@export var radius_tiles: float = 1.0
@export var knockback_speed: float = 520.0


func effect_kind() -> StringName:
	return &"knockback_area"


func preview_radius_tiles() -> float:
	return radius_tiles


func execute(item: Node2D) -> Array[Node]:
	var radius_px: float = GameState.tiles(radius_tiles) + TARGET_PADDING_PX
	var affected: Array[Node] = []
	var targets: Array[Node] = item.get_tree().get_nodes_in_group("enemies")
	targets.append_array(item.get_tree().get_nodes_in_group("player"))
	for target in targets:
		var body := target as Node2D
		if body == null or body.global_position.distance_to(item.global_position) > radius_px:
			continue
		var away := (body.global_position - item.global_position)
		var dir := away.normalized() if away.length() > 1.0 else Vector2.DOWN
		affected.append(target)
		if target.is_in_group("enemies"):
			(target as Enemy).apply_knockback(dir * knockback_speed)
		else:
			(target as Player).apply_knockback(dir * knockback_speed)
	var ring := EXPANDING_RING.new() as Node2D
	item.get_tree().current_scene.add_child(ring)
	ring.global_position = item.global_position
	ring.setup(radius_px, Color(0.9, 0.4, 0.8))
	var burst := IMPACT_BURST.new() as CPUParticles2D
	item.get_tree().current_scene.add_child(burst)
	burst.global_position = item.global_position
	burst.burst(Color(0.9, 0.5, 0.85), 12)
	return affected
