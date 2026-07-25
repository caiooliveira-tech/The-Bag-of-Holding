## One-shot fading circle for instant area effects (e.g. freeze).
## No class_name on purpose — consumers preload this script by path.
extends Node2D

var _radius_px: float = 32.0
var _color: Color = Color.WHITE


## Call AFTER add_child() so the fade tween can start immediately.
func setup(radius_px: float, color: Color, duration: float = 0.45) -> void:
	_radius_px = radius_px
	_color = color
	queue_redraw()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius_px, _color)
	draw_arc(Vector2.ZERO, _radius_px, 0.0, TAU, 32, Color(_color, 0.9), 2.0)
