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

## Smart chaser steering + lunge (Spec 015, melee only).
@export_group("Chaser")
@export var separation_radius_tiles: float = 1.3
@export var separation_weight: float = 1.1
@export var strafe_weight: float = 0.35
@export var lunge_range_tiles: float = 2.2
@export var lunge_windup: float = 0.35
@export var lunge_speed: float = 340.0
@export var lunge_duration: float = 0.2
@export var lunge_recover: float = 0.5
