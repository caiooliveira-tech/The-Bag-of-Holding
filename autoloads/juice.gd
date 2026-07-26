## Global juice helpers (autoload "Juice"). Hitstop is genuinely global —
## it scales the whole engine clock — so it earns an autoload (Spec 010, G1).
extends Node

## Briefly slows the whole game for impact, then restores real-time.
## Overlapping calls extend correctly: only the most recent restore wins,
## so a later hit re-slows and re-schedules instead of snapping back early.
var _token: int = 0


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
