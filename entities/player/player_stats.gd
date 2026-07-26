class_name PlayerStats
extends Resource

@export var move_speed: float = 160.0
@export var dash_speed: float = 480.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.4
@export var max_health: int = 5
@export var kick_range_tiles: float = 1.0
@export var kick_damage: int = 1
## Game feel (Spec 010, G1): knockback impulse when hit by an enemy.
@export var hit_knockback_speed: float = 260.0
@export var hit_knockback_decay: float = 900.0
