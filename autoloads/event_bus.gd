## Global event dispatcher (autoload "EventBus").
## Systems EMIT here to announce facts; listeners connect in _ready().
## Never call gameplay methods from here — signals announce, direct calls execute.
extends Node

# Signals here are emitted by other scripts, so the per-class
# "unused signal" warning does not apply to an event bus.
@warning_ignore("unused_signal")
signal player_damaged(amount: int, source: Node)
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal enemy_died(enemy: Node)
@warning_ignore("unused_signal")
signal room_cleared
@warning_ignore("unused_signal")
signal item_drawn(item_id: StringName)
@warning_ignore("unused_signal")
signal item_thrown(item_id: StringName, position: Vector2, direction: Vector2)
@warning_ignore("unused_signal")
signal item_effect_triggered(item_id: StringName, position: Vector2)
