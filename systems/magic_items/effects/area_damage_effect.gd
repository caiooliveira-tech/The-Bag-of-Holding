## area_damage effect_type (Fire Orb and future heavy variants).
class_name AreaDamageEffect
extends MagicItemEffect

## Power tier maps directly to discrete hits dealt (glossary: Light/Medium/Heavy).
enum DamageTier { LIGHT = 1, MEDIUM = 2, HEAVY = 3 }

const EXPANDING_RING: GDScript = preload("res://systems/juice/expanding_ring.gd")

## Bodies are treated as points; pad the radius so a body visually touching
## the circle still counts (half a graybox body).
const TARGET_PADDING_PX: float = 12.0

@export var damage_tier: DamageTier = DamageTier.MEDIUM
@export var radius_tiles: float = 1.0
@export var linger_seconds: float = 1.0


func effect_kind() -> StringName:
	return &"area_damage"


func preview_radius_tiles() -> float:
	return radius_tiles


func execute(item: Node2D) -> Array[Node]:
	var zone := DamageLingerZone.new()
	var radius_px: float = GameState.tiles(radius_tiles) + TARGET_PADDING_PX
	zone.setup(damage_tier, radius_px, linger_seconds)
	item.get_tree().current_scene.add_child(zone)
	zone.global_position = item.global_position
	# Explosion ring (Spec 010, G4): the "BOOM" instant, over the linger area.
	var ring := EXPANDING_RING.new() as Node2D
	item.get_tree().current_scene.add_child(ring)
	ring.global_position = item.global_position
	ring.setup(radius_px, Color(1.0, 0.7, 0.25))
	return zone.apply_hits()
