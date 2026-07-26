## Landing/danger reticle shown while an item is in flight (Spec 010, G2).
## Draws the blast footprint at the spot the item will land, so the player
## reads friendly-fire risk before it arrives. Pulses; freed on landing.
extends Node2D

var _radius: float = 20.0
var _color: Color = Color(1.0, 0.8, 0.2)


func setup(radius_px: float, color: Color) -> void:
	_radius = radius_px
	_color = color
	queue_redraw()
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.35, 0.35)
	tween.tween_property(self, "modulate:a", 0.9, 0.35)


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color(_color, 0.16))
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 32, Color(_color, 0.9), 2.0)
