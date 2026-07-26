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
# Carries the full resource so UI can render color/name without a catalog.
@warning_ignore("unused_signal")
signal item_drawn(item_data: MagicItemResource)
@warning_ignore("unused_signal")
signal item_thrown(item_id: StringName, position: Vector2, direction: Vector2)
# effect_kind ("area_damage" / "freeze_area") lets feedback pick a profile
# (shake vs. zoom punch) without hardcoding item ids.
@warning_ignore("unused_signal")
signal item_effect_triggered(item_id: StringName, position: Vector2, effect_kind: StringName)
# Fired for SFX/feedback (audio hooks, Spec 013).
@warning_ignore("unused_signal")
signal enemy_damaged(enemy: Node)
@warning_ignore("unused_signal")
signal player_dashed
@warning_ignore("unused_signal")
signal player_kicked
@warning_ignore("unused_signal")
signal door_opened
