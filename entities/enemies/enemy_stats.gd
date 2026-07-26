class_name EnemyStats
extends Resource

@export var move_speed: float = 100.0
@export var detection_radius_tiles: float = 5.0
@export var attack_range_tiles: float = 1.0
@export var attack_cooldown: float = 0.8
@export var damage: int = 1
@export var max_hits: int = 2
## Ranged archetype (Spec 014): kite to a distance and shoot instead of melee.
@export var is_ranged: bool = false
@export var preferred_distance_tiles: float = 4.0
@export var shoot_cooldown: float = 1.5
