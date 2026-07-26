## Difficulty knobs (Spec 018). Data only — consumers (player, enemy, HUD)
## read these through GameState.difficulty at ready; base .tres stats are
## never mutated. Item countdowns are deliberately NOT here: the countdown
## puzzle never changes with difficulty (design stance, Spec 018).
class_name DifficultyResource
extends Resource

@export var display_name: String = "Wizard"

## Player durability.
@export var player_max_health: int = 5
@export var hit_iframe_duration: float = 0.5

## Enemy pressure — multipliers applied on top of each enemy's base stats
## at spawn (covers melee attack and ranged shoot cooldowns alike).
@export var enemy_speed_mult: float = 1.0
@export var enemy_cooldown_mult: float = 1.0
@export var enemy_detection_mult: float = 1.0
