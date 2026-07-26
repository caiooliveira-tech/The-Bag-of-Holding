## Quick expanding ring that fades and frees itself (Spec 010, G4).
## Punctuates the explosion instant, distinct from the 1 s linger area.
extends Node2D

var _radius: float = 32.0
var _color: Color = Color(1.0, 0.7, 0.2)


func setup(radius_px: float, color: Color) -> void:
	_radius = radius_px
	_color = color
	queue_redraw()
	scale = Vector2(0.35, 0.35)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)


func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 40, Color(_color, 0.95), 3.0)
