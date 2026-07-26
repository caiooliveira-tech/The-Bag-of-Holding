## Global juice helpers (autoload "Juice"). Hitstop scales the whole engine
## clock and rumble drives the controller — both are genuinely global, so they
## earn an autoload (Spec 010, G1 + G5).
extends Node

## Briefly slows the whole game for impact, then restores real-time.
## Overlapping calls extend correctly: only the most recent restore wins,
## so a later hit re-slows and re-schedules instead of snapping back early.
var _token: int = 0


func _ready() -> void:
	# Rumble hooks (Spec 010, G5): no-op on keyboard, felt on a gamepad.
	EventBus.item_effect_triggered.connect(_on_item_effect_triggered)
	EventBus.player_damaged.connect(_on_player_damaged)


func rumble(weak: float, strong: float, duration: float) -> void:
	if Input.get_connected_joypads().is_empty():
		return
	Input.start_joy_vibration(0, weak, strong, duration)


func _on_item_effect_triggered(_id: StringName, _pos: Vector2, kind: StringName) -> void:
	if kind == &"area_damage":
		rumble(0.3, 0.6, 0.18)


func _on_player_damaged(_amount: int, _source: Node) -> void:
	rumble(0.2, 0.45, 0.15)


## `scale` 0..1 of normal speed; `duration` is REAL seconds (ignores the slow).
func hitstop(duration: float, scale: float = 0.05) -> void:
	_token += 1
	var my_token := _token
	Engine.time_scale = scale
	# ignore_time_scale = true → the timer counts wall-clock seconds even
	# though the engine clock is slowed, so the restore always fires.
	var timer := get_tree().create_timer(duration, true, false, true)
	await timer.timeout
	if my_token == _token:
		Engine.time_scale = 1.0
